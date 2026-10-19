import Foundation
import Observation

/// Remembers whether the person chose to browse without an account.
public protocol GuestModeStoring: AnyObject {
    var isGuest: Bool { get set }
}

public final class UserDefaultsGuestModeStore: GuestModeStoring {
    private let defaults: UserDefaults
    private let key = "session.isGuest"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var isGuest: Bool {
        get { defaults.bool(forKey: key) }
        set { defaults.set(newValue, forKey: key) }
    }
}

public final class InMemoryGuestModeStore: GuestModeStoring {
    public var isGuest: Bool

    public init(isGuest: Bool = false) {
        self.isGuest = isGuest
    }
}

/// Owns the app's authentication state and every auth action the UI can take.
@MainActor
@Observable
public final class SessionModel {
    public enum State: Equatable {
        case loading
        case signedOut
        case signedIn(AppUser)
    }

    public private(set) var state: State = .loading
    public private(set) var isWorking = false
    public var errorMessage: String?
    public var infoMessage: String?

    @ObservationIgnored private let auth: AuthServicing
    @ObservationIgnored private let guestStore: GuestModeStoring

    public init(auth: AuthServicing, guestStore: GuestModeStoring = UserDefaultsGuestModeStore()) {
        self.auth = auth
        self.guestStore = guestStore
    }

    public var currentUser: AppUser? {
        if case .signedIn(let user) = state { return user }
        return nil
    }

    /// Follows the backend's auth state for as long as the calling task lives (use from `.task`).
    public func observeAuthState() async {
        for await user in auth.authStateChanges() {
            apply(user)
        }
    }

    public func signIn(email: String, password: String) async {
        if let error = CredentialValidator.validateSignIn(email: email, password: password) {
            errorMessage = error.message
            return
        }
        await perform {
            let user = try await self.auth.signIn(email: Self.normalized(email), password: password)
            self.guestStore.isGuest = false
            self.apply(user)
        }
    }

    public func signUp(name: String, email: String, password: String, confirmation: String) async {
        if let error = CredentialValidator.validateSignUp(name: name, email: email, password: password, confirmation: confirmation) {
            errorMessage = error.message
            return
        }
        await perform {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let user = try await self.auth.signUp(name: trimmedName, email: Self.normalized(email), password: password)
            self.guestStore.isGuest = false
            self.apply(user)
        }
    }

    /// Returns `true` when the reset email was requested.
    @discardableResult
    public func sendPasswordReset(email: String) async -> Bool {
        if let error = CredentialValidator.validateEmail(email) {
            errorMessage = error.message
            return false
        }
        return await perform {
            let address = Self.normalized(email)
            try await self.auth.sendPasswordReset(email: address)
            self.infoMessage = "If an account exists for \(address), a reset link is on its way."
        }
    }

    public func continueAsGuest() {
        clearMessages()
        guestStore.isGuest = true
        state = .signedIn(.guest)
    }

    /// Signs out of an account, or leaves guest mode, and returns to the sign-in screen.
    public func signOut() {
        clearMessages()
        do {
            if currentUser?.isGuest == false {
                try auth.signOut()
            }
            guestStore.isGuest = false
            state = .signedOut
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    /// Permanently deletes the account. Returns `true` on success so the caller can clear local data.
    @discardableResult
    public func deleteAccount() async -> Bool {
        guard let user = currentUser, !user.isGuest else { return false }
        return await perform {
            try await self.auth.deleteAccount()
            self.state = .signedOut
        }
    }

    public func clearMessages() {
        errorMessage = nil
        infoMessage = nil
    }

    // MARK: - Private

    private func apply(_ user: AppUser?) {
        if let user {
            state = .signedIn(user)
        } else if guestStore.isGuest {
            state = .signedIn(.guest)
        } else {
            state = .signedOut
        }
    }

    @discardableResult
    private func perform(_ work: () async throws -> Void) async -> Bool {
        clearMessages()
        isWorking = true
        defer { isWorking = false }
        do {
            try await work()
            return true
        } catch {
            errorMessage = Self.message(for: error)
            return false
        }
    }

    private static func normalized(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func message(for error: Error) -> String {
        (error as? AuthFailure)?.message ?? error.localizedDescription
    }
}
