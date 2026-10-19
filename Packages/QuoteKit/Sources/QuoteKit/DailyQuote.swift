import Foundation

/// Picks one quote per calendar day. Everyone sees the same quote on the same local date,
/// and consecutive days are scattered across the collection instead of walking it in order.
public enum DailyQuote {
    public static func quote(
        for date: Date,
        calendar: Calendar = .current,
        from quotes: [Quote] = BundledQuotes.all
    ) -> Quote? {
        guard !quotes.isEmpty else { return nil }
        return quotes[index(for: date, calendar: calendar, count: quotes.count)]
    }

    static func index(for date: Date, calendar: Calendar, count: Int) -> Int {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        let year: Int = parts.year ?? 0
        let month: Int = parts.month ?? 0
        let day: Int = parts.day ?? 0
        let dayKey = UInt64(year * 10_000 + month * 100 + day)
        return Int(splitMix64(dayKey) % UInt64(count))
    }

    /// SplitMix64: a tiny, well-distributed, deterministic mixer (stable across launches and platforms,
    /// unlike `Hasher`, which is seeded per process).
    static func splitMix64(_ seed: UInt64) -> UInt64 {
        var z = seed &+ 0x9E37_79B9_7F4A_7C15
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
