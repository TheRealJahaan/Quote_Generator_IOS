import XCTest
@testable import QuoteKit

final class QuoteRepositoryTests: XCTestCase {
    func testUsesRemoteWhenAvailable() async {
        let repository = QuoteRepository(primary: SequenceProvider([makeQuote("r1")]), fallback: SequenceProvider([makeQuote("b1")]))
        let result = await repository.nextQuote(excluding: nil)
        XCTAssertEqual(result.quote.id, "r1")
        XCTAssertEqual(result.source, .remote)
    }

    func testFallsBackToOfflineQuotesWhenRemoteFails() async {
        let repository = QuoteRepository(primary: FailingProvider(), fallback: SequenceProvider([makeQuote("b1")]))
        let result = await repository.nextQuote(excluding: nil)
        XCTAssertEqual(result.quote.id, "b1")
        XCTAssertEqual(result.source, .offline)
    }

    func testSkipsTheQuoteAlreadyOnScreen() async {
        let primary = SequenceProvider([makeQuote("same"), makeQuote("same"), makeQuote("fresh")])
        let repository = QuoteRepository(primary: primary, fallback: FailingProvider())
        let result = await repository.nextQuote(excluding: "same")
        XCTAssertEqual(result.quote.id, "fresh")
    }

    func testStillReturnsSomethingWhenEverythingFails() async {
        let repository = QuoteRepository(primary: FailingProvider(), fallback: FailingProvider())
        let result = await repository.nextQuote(excluding: nil)
        XCTAssertEqual(result.quote, BundledQuotes.all[0])
        XCTAssertEqual(result.source, .offline)
    }
}
