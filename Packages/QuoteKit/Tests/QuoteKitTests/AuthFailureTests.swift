import XCTest
@testable import QuoteKit

final class AuthFailureTests: XCTestCase {
    func testMapsKnownFirebaseCodes() {
        let cases: [(Int, AuthFailure)] = [
            (17008, .invalidEmail),
            (17009, .wrongCredentials),
            (17011, .wrongCredentials),
            (17004, .wrongCredentials),
            (17007, .emailAlreadyInUse),
            (17026, .weakPassword),
            (17005, .userDisabled),
            (17010, .tooManyRequests),
            (17020, .network),
            (17014, .requiresRecentLogin)
        ]
        for (code, expected) in cases {
            XCTAssertEqual(AuthFailure(firebaseCode: code, fallbackMessage: "x"), expected, "code \(code)")
        }
    }

    func testUnknownCodeKeepsBackendMessage() {
        let failure = AuthFailure(firebaseCode: 99_999, fallbackMessage: "Something odd happened.")
        XCTAssertEqual(failure, .other("Something odd happened."))
        XCTAssertEqual(failure.message, "Something odd happened.")
    }

    func testFirstNamePrefersDisplayNameThenEmail() {
        XCTAssertEqual(AppUser(id: "1", email: "ana@x.io", displayName: "Ana Lopez").firstName, "Ana")
        XCTAssertEqual(AppUser(id: "1", email: "ana@x.io", displayName: nil).firstName, "ana")
        XCTAssertNil(AppUser.guest.firstName)
    }
}
