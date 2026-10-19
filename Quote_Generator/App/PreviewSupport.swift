import Foundation
import QuoteKit

extension AppUser {
    static let preview = AppUser(id: "preview-user", email: "jahaan@example.com", displayName: "Jahaan Suthar")
}

extension SessionModel {
    /// A session backed by the in-memory auth service, for SwiftUI previews.
    static func preview(signedInAs user: AppUser? = nil) -> SessionModel {
        let auth = InMemoryAuthService(signedInAs: user)
        auth.register(email: "jahaan@example.com", password: "password1", displayName: "Jahaan Suthar")
        return SessionModel(auth: auth, guestStore: InMemoryGuestModeStore())
    }
}
