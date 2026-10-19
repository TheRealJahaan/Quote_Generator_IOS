import XCTest
@testable import QuoteKit

final class QuoteServiceTests: XCTestCase {
    func testDecodesDummyJSONPayload() async throws {
        let client = StubHTTPClient(json: #"{"id": 42, "quote": "  Keep going.  ", "author": "Someone "}"#)
        let quote = try await RemoteQuoteService(client: client).randomQuote()
        XCTAssertEqual(quote, Quote(id: "dummyjson-42", text: "Keep going.", author: "Someone"))
    }

    func testThrowsOnServerError() async {
        let client = StubHTTPClient(json: "{}", statusCode: 503)
        do {
            _ = try await RemoteQuoteService(client: client).randomQuote()
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? QuoteServiceError, .badStatus(503))
        }
    }

    func testThrowsOnMalformedJSON() async {
        let client = StubHTTPClient(json: #"{"unexpected": true}"#)
        do {
            _ = try await RemoteQuoteService(client: client).randomQuote()
            XCTFail("Expected an error")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testBundledQuotesAreUniqueAndComplete() {
        let quotes = BundledQuotes.all
        XCTAssertGreaterThanOrEqual(quotes.count, 30)
        XCTAssertEqual(Set(quotes.map(\.id)).count, quotes.count, "ids must be unique")
        XCTAssertEqual(Set(quotes.map(\.text)).count, quotes.count, "texts must be unique")
        XCTAssertTrue(quotes.allSatisfy { !$0.text.isEmpty && !$0.author.isEmpty })
    }

    func testShareTextIncludesAuthor() {
        XCTAssertEqual(Quote(id: "1", text: "Real artists ship.", author: "Steve Jobs").shareText, "“Real artists ship.” — Steve Jobs")
    }
}
