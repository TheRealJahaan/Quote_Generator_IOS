import XCTest
@testable import QuoteKit

final class DailyQuoteTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    func testSameQuoteAllDay() {
        let morning = DailyQuote.quote(for: date(2026, 10, 19, hour: 0), calendar: calendar)
        let night = DailyQuote.quote(for: date(2026, 10, 19, hour: 23), calendar: calendar)
        XCTAssertEqual(morning, night)
    }

    func testQuotesChangeAcrossDays() {
        let ids = (1...30).compactMap { DailyQuote.quote(for: date(2026, 11, $0), calendar: calendar)?.id }
        XCTAssertGreaterThan(Set(ids).count, 10, "a month of days should cover many different quotes")
    }

    func testIndexStaysInRange() {
        for day in 1...28 {
            let index = DailyQuote.index(for: date(2027, 2, day), calendar: calendar, count: 7)
            XCTAssertTrue((0..<7).contains(index))
        }
    }

    func testEmptyCollectionHasNoDailyQuote() {
        XCTAssertNil(DailyQuote.quote(for: Date(), calendar: calendar, from: []))
    }
}
