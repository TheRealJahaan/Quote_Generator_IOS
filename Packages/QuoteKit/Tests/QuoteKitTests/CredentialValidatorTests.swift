import XCTest
@testable import QuoteKit

final class CredentialValidatorTests: XCTestCase {
    func testAcceptsOrdinaryEmails() {
        for email in ["a@b.co", "jahaan.suthar@example.com", "  padded@example.org  ", "x+tag@sub.domain.io"] {
            XCTAssertTrue(CredentialValidator.isValidEmail(email), email)
        }
    }

    func testRejectsMalformedEmails() {
        for email in ["", "plain", "@example.com", "a@", "a@b", "a@b.", "a@.com", "a b@example.com", "a@@example.com", "a@b.c"] {
            XCTAssertFalse(CredentialValidator.isValidEmail(email), email)
        }
    }

    func testSignInValidation() {
        XCTAssertEqual(CredentialValidator.validateSignIn(email: "", password: "x"), .missingEmail)
        XCTAssertEqual(CredentialValidator.validateSignIn(email: "nope", password: "x"), .invalidEmail)
        XCTAssertEqual(CredentialValidator.validateSignIn(email: "a@b.co", password: ""), .missingPassword)
        XCTAssertNil(CredentialValidator.validateSignIn(email: "a@b.co", password: "x"))
    }

    func testSignUpValidationOrder() {
        XCTAssertEqual(CredentialValidator.validateSignUp(name: "  ", email: "a@b.co", password: "abc12345", confirmation: "abc12345"), .missingName)
        XCTAssertEqual(CredentialValidator.validateSignUp(name: "Ana", email: "bad", password: "abc12345", confirmation: "abc12345"), .invalidEmail)
        XCTAssertEqual(CredentialValidator.validateSignUp(name: "Ana", email: "a@b.co", password: "abc1", confirmation: "abc1"), .passwordTooShort(minimum: 8))
        XCTAssertEqual(CredentialValidator.validateSignUp(name: "Ana", email: "a@b.co", password: "abcdefgh", confirmation: "abcdefgh"), .passwordNeedsLetterAndNumber)
        XCTAssertEqual(CredentialValidator.validateSignUp(name: "Ana", email: "a@b.co", password: "abc12345", confirmation: "abc12346"), .passwordsDoNotMatch)
        XCTAssertNil(CredentialValidator.validateSignUp(name: "Ana", email: "a@b.co", password: "abc12345", confirmation: "abc12345"))
    }

    func testEveryValidationErrorHasAMessage() {
        let errors: [ValidationError] = [.missingName, .missingEmail, .invalidEmail, .missingPassword, .passwordTooShort(minimum: 8), .passwordNeedsLetterAndNumber, .passwordsDoNotMatch]
        XCTAssertTrue(errors.allSatisfy { !$0.message.isEmpty })
        XCTAssertTrue(ValidationError.passwordTooShort(minimum: 8).message.contains("8"))
    }
}
