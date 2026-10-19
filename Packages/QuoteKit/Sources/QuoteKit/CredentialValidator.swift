import Foundation

/// A problem with what the user typed, caught before any network call.
public enum ValidationError: Error, Equatable, Sendable {
    case missingName
    case missingEmail
    case invalidEmail
    case missingPassword
    case passwordTooShort(minimum: Int)
    case passwordNeedsLetterAndNumber
    case passwordsDoNotMatch

    public var message: String {
        switch self {
        case .missingName: "Please enter your name."
        case .missingEmail: "Please enter your email."
        case .invalidEmail: "That email address doesn't look right."
        case .missingPassword: "Please enter your password."
        case .passwordTooShort(let minimum): "Your password needs at least \(minimum) characters."
        case .passwordNeedsLetterAndNumber: "Use at least one letter and one number in your password."
        case .passwordsDoNotMatch: "The passwords don't match."
        }
    }
}

public enum CredentialValidator {
    public static let minimumPasswordLength = 8

    /// A pragmatic check: one `@`, a non-empty local part, and a dotted domain with no empty labels.
    /// The auth backend remains the source of truth; this only catches obvious typos early.
    public static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.contains(where: \.isWhitespace) else { return false }
        let parts = trimmed.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return false }
        let labels = parts[1].split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count >= 2, labels.allSatisfy({ !$0.isEmpty }) else { return false }
        return (labels.last?.count ?? 0) >= 2
    }

    public static func validateSignIn(email: String, password: String) -> ValidationError? {
        if let error = validateEmail(email) { return error }
        if password.isEmpty { return .missingPassword }
        return nil
    }

    public static func validateSignUp(name: String, email: String, password: String, confirmation: String) -> ValidationError? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return .missingName }
        if let error = validateEmail(email) { return error }
        if password.isEmpty { return .missingPassword }
        if password.count < minimumPasswordLength { return .passwordTooShort(minimum: minimumPasswordLength) }
        if !password.contains(where: \.isLetter) || !password.contains(where: \.isNumber) {
            return .passwordNeedsLetterAndNumber
        }
        if password != confirmation { return .passwordsDoNotMatch }
        return nil
    }

    public static func validateEmail(_ email: String) -> ValidationError? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .missingEmail }
        if !isValidEmail(trimmed) { return .invalidEmail }
        return nil
    }
}
