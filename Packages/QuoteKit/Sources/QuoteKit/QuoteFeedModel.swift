import Foundation
import Observation

/// Drives the main quote screen: the quote of the day, fetching new quotes, and stepping back through history.
@MainActor
@Observable
public final class QuoteFeedModel {
    public private(set) var current: Quote
    public private(set) var source: QuoteSource = .offline
    public private(set) var isLoading = false
    public private(set) var history: [Quote] = []

    /// The quote chosen for today; the screen labels it "Quote of the day" while it is showing.
    public let dailyQuote: Quote

    @ObservationIgnored private let repository: QuoteRepository
    @ObservationIgnored private let historyLimit: Int

    public init(repository: QuoteRepository, dailyQuote: Quote, historyLimit: Int = 25) {
        self.repository = repository
        self.dailyQuote = dailyQuote
        self.current = dailyQuote
        self.historyLimit = historyLimit
    }

    public var isShowingDailyQuote: Bool { current == dailyQuote }
    public var canGoBack: Bool { !history.isEmpty }

    public func loadNext() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        let result = await repository.nextQuote(excluding: current.id)
        history.append(current)
        if history.count > historyLimit {
            history.removeFirst(history.count - historyLimit)
        }
        current = result.quote
        source = result.source
    }

    public func goBack() {
        guard let previous = history.popLast() else { return }
        current = previous
    }
}
