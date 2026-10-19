import Foundation

/// The signed-in person, independent of any auth SDK.
public struct AppUser: Equatable, Hashable, Sendable {
    public let id: String
    public let email: String?
    public let displayName: String?
    public let isGuest: Bool

    public init(id: String, email: String?, displayName: String?, isGuest: Bool = false) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.isGuest = isGuest
    }

    /// Guests keep favorites on this device only, under a fixed local id.
    public static let guest = AppUser(id: "local-guest", email: nil, displayName: nil, isGuest: true)

    /// First name for greetings, falling back to the part of the email before `@`.
    public var firstName: String? {
        if let name = displayName?.split(separator: " ").first, !name.isEmpty { return String(name) }
        if let local = email?.split(separator: "@").first, !local.isEmpty { return String(local) }
        return nil
    }
}

/// Everything the app needs from an authentication backend. The app ships a Firebase implementation;
/// `InMemoryAuthService` backs previews and tests.
@MainActor
public protocol AuthServicing: AnyObject {
    /// Emits the current user immediately, then again whenever it changes.
    func authStateChanges() -> AsyncStream<AppUser?>
    func signIn(email: String, password: String) async throws -> AppUser
    func signUp(name: String, email: String, password: String) async throws -> AppUser
    func sendPasswordReset(email: String) async throws
    func signOut() throws
    func deleteAccount() async throws
}

/// Auth failures translated into language a person can act on.
public enum AuthFailure: Error, Equatable, Sendable {
    case invalidEmail
    case wrongCredentials
    case emailAlreadyInUse
    case weakPassword
    case userDisabled
    case tooManyRequests
    case network
    case requiresRecentLogin
    case other(String)

    /// Maps Firebase Auth error codes (`FIRAuthErrorDomain`) to a failure.
    public init(firebaseCode code: Int, fallbackMessage: String) {
        switch code {
        case 17008: self = .invalidEmail
        case 17009, 17011, 17004: self = .wrongCredentials  // wrong password, user not found, invalid credential
        case 17007: self = .emailAlreadyInUse
        case 17026: self = .weakPassword
        case 17005: self = .userDisabled
        case 17010: self = .tooManyRequests
        case 17020: self = .network
        case 17014: self = .requiresRecentLogin
        default: self = .other(fallbackMessage)
        }
    }

    public var message: String {
        switch self {
        case .invalidEmail: "That email address doesn't look right."
        case .wrongCredentials: "That email and password don't match an account."
        case .emailAlreadyInUse: "An account with this email already exists. Try signing in instead."
        case .weakPassword: "Choose a stronger password."
        case .userDisabled: "This account has been disabled."
        case .tooManyRequests: "Too many attempts. Please wait a moment and try again."
        case .network: "You appear to be offline. Check your connection and try again."
        case .requiresRecentLogin: "For your security, sign out and sign back in, then try again."
        case .other(let message): message
        }
    }
}

/// A fully in-memory auth backend for SwiftUI previews and unit tests.
@MainActor
public final class InMemoryAuthService: AuthServicing {
    private struct Account {
        var password: String
        var user: AppUser
    }

    private var accounts: [String: Account] = [:]
    private var continuations: [UUID: AsyncStream<AppUser?>.Continuation] = [:]
    public private(set) var currentUser: AppUser?
    public private(set) var passwordResetRequests: [String] = []

    public init(signedInAs user: AppUser? = nil) {
        currentUser = user
    }

    /// Seeds an account that can sign in with the given password.
    public func register(email: String, password: String, displayName: String? = nil) {
        let key = email.lowercased()
        accounts[key] = Account(password: password, user: AppUser(id: "user-\(accounts.count + 1)", email: key, displayName: displayName))
    }

    public func authStateChanges() -> AsyncStream<AppUser?> {
        let id = UUID()
        return AsyncStream { continuation in
            continuations[id] = continuation
            continuation.yield(currentUser)
        }
    }

    public func signIn(email: String, password: String) async throws -> AppUser {
        guard let account = accounts[email.lowercased()], account.password == password else {
            throw AuthFailure.wrongCredentials
        }
        setCurrent(account.user)
        return account.user
    }

    public func signUp(name: String, email: String, password: String) async throws -> AppUser {
        let key = email.lowercased()
        guard accounts[key] == nil else { throw AuthFailure.emailAlreadyInUse }
        register(email: key, password: password, displayName: name)
        let user = accounts[key]!.user
        setCurrent(user)
        return user
    }

    public func sendPasswordReset(email: String) async throws {
        passwordResetRequests.append(email)
    }

    public func signOut() throws {
        setCurrent(nil)
    }

    public func deleteAccount() async throws {
        guard let email = currentUser?.email else { return }
        accounts[email] = nil
        setCurrent(nil)
    }

    private func setCurrent(_ user: AppUser?) {
        currentUser = user
        continuations.values.forEach { $0.yield(user) }
    }
}
