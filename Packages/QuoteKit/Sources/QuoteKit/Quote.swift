import Foundation

/// A single quote and the person it is attributed to.
public struct Quote: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let text: String
    public let author: String

    public init(id: String, text: String, author: String) {
        self.id = id
        self.text = text
        self.author = author
    }

    /// The quote formatted for sharing or copying, e.g. `“Real artists ship.” — Steve Jobs`.
    public var shareText: String {
        "“\(text)” — \(author)"
    }
}

/// Where a quote came from, so the UI can tell the reader when it is offline.
public enum QuoteSource: Equatable, Sendable {
    case remote
    case offline
}
