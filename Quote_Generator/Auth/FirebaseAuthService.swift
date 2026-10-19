import Foundation
import FirebaseAuth
import QuoteKit

/// `AuthServicing` backed by Firebase Authentication (email and password).
final class FirebaseAuthService: AuthServicing {
    private let auth: Auth

    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }

    func authStateChanges() -> AsyncStream<AppUser?> {
        AsyncStream { continuation in
            let handle = auth.addStateDidChangeListener { _, user in
                continuation.yield(user.map(AppUser.init(firebaseUser:)))
            }
            let auth = self.auth
            continuation.onTermination = { _ in
                auth.removeStateDidChangeListener(handle)
            }
        }
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return AppUser(firebaseUser: result.user)
        } catch {
            throw Self.translate(error)
        }
    }

    func signUp(name: String, email: String, password: String) async throws -> AppUser {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let change = result.user.createProfileChangeRequest()
            change.displayName = name
            try await change.commitChanges()
            return AppUser(id: result.user.uid, email: result.user.email, displayName: name)
        } catch {
            throw Self.translate(error)
        }
    }

    func sendPasswordReset(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw Self.translate(error)
        }
    }

    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw Self.translate(error)
        }
    }

    func deleteAccount() async throws {
        guard let user = auth.currentUser else { return }
        do {
            try await user.delete()
        } catch {
            throw Self.translate(error)
        }
    }

    nonisolated private static func translate(_ error: Error) -> Error {
        let nsError = error as NSError
        guard nsError.domain == "FIRAuthErrorDomain" else { return error }
        return AuthFailure(firebaseCode: nsError.code, fallbackMessage: nsError.localizedDescription)
    }
}

private extension AppUser {
    nonisolated init(firebaseUser user: FirebaseAuth.User) {
        self.init(id: user.uid, email: user.email, displayName: user.displayName)
    }
}
