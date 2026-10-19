import SwiftUI
import QuoteKit

struct QuoteCard: View {
    let quote: Quote
    var caption: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                Spacer()
                if let caption {
                    Text(caption)
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(.tint)
                }
            }

            Text(quote.text)
                .font(.system(.title2, design: .serif, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("— \(quote.author)")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .cardSurface(cornerRadius: 28)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(quote.text), by \(quote.author)")
    }
}

#Preview {
    QuoteCard(quote: BundledQuotes.all[0], caption: "Quote of the day")
        .padding()
        .background(GradientBackground())
}
