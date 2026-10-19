import Foundation

/// Combines the live API with the bundled collection: tries the network first,
/// falls back to offline quotes on any failure, and avoids showing the same quote twice in a row.
public struct QuoteRepository: Sendable {
    private let primary: QuoteProviding
    private let fallback: QuoteProviding
    private let maxAttempts: Int

    public init(primary: QuoteProviding, fallback: QuoteProviding, maxAttempts: Int = 3) {
        self.primary = primary
        self.fallback = fallback
        self.maxAttempts = max(1, maxAttempts)
    }

    /// The production configuration: DummyJSON, backed by the bundled quotes.
    public static let live = QuoteRepository(primary: RemoteQuoteService(), fallback: BundledQuoteService())

    /// Offline-only configuration, handy for previews and tests.
    public static let offline = QuoteRepository(primary: BundledQuoteService(), fallback: BundledQuoteService())

    public func nextQuote(excluding currentID: String?) async -> (quote: Quote, source: QuoteSource) {
        if let quote = await fetch(from: primary, excluding: currentID) {
            return (quote, .remote)
        }
        if let quote = await fetch(from: fallback, excluding: currentID) {
            return (quote, .offline)
        }
        return (BundledQuotes.all[0], .offline)
    }

    private func fetch(from provider: QuoteProviding, excluding currentID: String?) async -> Quote? {
        var last: Quote?
        for _ in 0..<maxAttempts {
            guard let quote = try? await provider.randomQuote() else { return last }
            if quote.id != currentID { return quote }
            last = quote
        }
        return last
    }
}
