import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Anything that can hand out a random quote.
public protocol QuoteProviding: Sendable {
    func randomQuote() async throws -> Quote
}

/// The minimal slice of networking the remote service needs, so tests can stub it.
public protocol HTTPClient: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

/// `URLSession`-backed client. Built on `dataTask` so it behaves the same on Apple platforms and Linux.
public struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: url) { data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let data, let response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: QuoteServiceError.emptyResponse)
                }
            }
            task.resume()
        }
    }
}

public enum QuoteServiceError: Error, Equatable {
    case emptyResponse
    case badStatus(Int)
    case noQuotesAvailable
}

/// Fetches random quotes from the public DummyJSON API (https://dummyjson.com/docs/quotes).
public struct RemoteQuoteService: QuoteProviding {
    public static let defaultEndpoint = URL(string: "https://dummyjson.com/quotes/random")!

    private let client: HTTPClient
    private let endpoint: URL

    public init(client: HTTPClient = URLSessionHTTPClient(), endpoint: URL = RemoteQuoteService.defaultEndpoint) {
        self.client = client
        self.endpoint = endpoint
    }

    public func randomQuote() async throws -> Quote {
        let (data, response) = try await client.data(from: endpoint)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw QuoteServiceError.badStatus(http.statusCode)
        }
        let payload = try JSONDecoder().decode(Payload.self, from: data)
        return Quote(
            id: "dummyjson-\(payload.id)",
            text: payload.quote.trimmingCharacters(in: .whitespacesAndNewlines),
            author: payload.author.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    private struct Payload: Decodable {
        let id: Int
        let quote: String
        let author: String
    }
}

/// Serves quotes from a fixed, in-app collection. Used offline and for the quote of the day.
public struct BundledQuoteService: QuoteProviding {
    public let quotes: [Quote]

    public init(quotes: [Quote] = BundledQuotes.all) {
        self.quotes = quotes
    }

    public func randomQuote() async throws -> Quote {
        guard let quote = quotes.randomElement() else { throw QuoteServiceError.noQuotesAvailable }
        return quote
    }
}
