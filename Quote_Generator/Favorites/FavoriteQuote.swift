import Foundation
import SwiftData
import QuoteKit

/// A quote someone saved. Stored on device with SwiftData and scoped to the account (or guest) that saved it.
@Model
final class FavoriteQuote {
    /// `userID` and `quoteID` combined, so the same person can't save the same quote twice.
    @Attribute(.unique) var key: String
    var userID: String
    var quoteID: String
    var text: String
    var author: String
    var savedAt: Date

    init(userID: String, quote: Quote, savedAt: Date = .now) {
        self.key = Self.key(userID: userID, quoteID: quote.id)
        self.userID = userID
        self.quoteID = quote.id
        self.text = quote.text
        self.author = quote.author
        self.savedAt = savedAt
    }

    var quote: Quote {
        Quote(id: quoteID, text: text, author: author)
    }

    static func key(userID: String, quoteID: String) -> String {
        "\(userID)|\(quoteID)"
    }
}

extension ModelContext {
    /// Saves the quote if it isn't a favorite yet, otherwise removes it. Returns whether it is now a favorite.
    @discardableResult
    func toggleFavorite(_ quote: Quote, for userID: String) -> Bool {
        let key = FavoriteQuote.key(userID: userID, quoteID: quote.id)
        let descriptor = FetchDescriptor<FavoriteQuote>(predicate: #Predicate { $0.key == key })
        if let existing = try? fetch(descriptor).first {
            delete(existing)
            return false
        }
        insert(FavoriteQuote(userID: userID, quote: quote))
        return true
    }

    /// Removes every favorite saved by one account, e.g. after the account is deleted.
    func deleteFavorites(for userID: String) {
        try? delete(model: FavoriteQuote.self, where: #Predicate { $0.userID == userID })
    }
}
