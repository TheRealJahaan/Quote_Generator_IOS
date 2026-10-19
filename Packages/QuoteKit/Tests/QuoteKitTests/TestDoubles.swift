import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import QuoteKit

struct StubHTTPClient: HTTPClient {
    var statusCode = 200
    var body: Data

    init(json: String, statusCode: Int = 200) {
        self.body = Data(json.utf8)
        self.statusCode = statusCode
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return (body, response)
    }
}

struct FailingProvider: QuoteProviding {
    struct Boom: Error {}
    func randomQuote() async throws -> Quote { throw Boom() }
}

/// Hands out a fixed sequence of quotes, then repeats the last one.
final class SequenceProvider: QuoteProviding, @unchecked Sendable {
    private let lock = NSLock()
    private var quotes: [Quote]

    init(_ quotes: [Quote]) {
        self.quotes = quotes
    }

    func randomQuote() async throws -> Quote {
        lock.lock()
        defer { lock.unlock() }
        return quotes.count > 1 ? quotes.removeFirst() : quotes[0]
    }
}

func makeQuote(_ id: String) -> Quote {
    Quote(id: id, text: "Quote \(id)", author: "Author \(id)")
}
