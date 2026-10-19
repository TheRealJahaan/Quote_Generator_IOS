import SwiftUI
import SwiftData
import UIKit
import QuoteKit

struct QuoteHomeView: View {
    let user: AppUser

    @State private var feed: QuoteFeedModel
    @State private var copiedTrigger = 0
    @State private var isShowingCopied = false
    @Query private var favorites: [FavoriteQuote]
    @Environment(\.modelContext) private var modelContext

    init(user: AppUser, repository: QuoteRepository = .live) {
        self.user = user
        let daily = DailyQuote.quote(for: .now) ?? BundledQuotes.all[0]
        _feed = State(initialValue: QuoteFeedModel(repository: repository, dailyQuote: daily))
        let userID = user.id
        _favorites = Query(filter: #Predicate<FavoriteQuote> { $0.userID == userID })
    }

    private var isFavorite: Bool {
        favorites.contains { $0.quoteID == feed.current.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                greeting

                QuoteCard(quote: feed.current, caption: feed.isShowingDailyQuote ? "Quote of the day" : nil)
                    .id(feed.current.id)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                    .overlay(alignment: .center) {
                        if feed.isLoading {
                            ProgressView()
                                .controlSize(.large)
                        }
                    }

                actions

                if feed.source == .offline && !feed.isShowingDailyQuote {
                    Label("Offline: showing quotes saved in the app.", systemImage: "wifi.slash")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                PrimaryButton(title: "New Quote", systemImage: "arrow.triangle.2.circlepath", isLoading: feed.isLoading) {
                    Task {
                        await feed.loadNext()
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: feed.current)
        }
        .background(GradientBackground())
        .navigationTitle("Inspire Me")
        .toolbarBackground(.hidden, for: .navigationBar)
        .overlay(alignment: .bottom) {
            if isShowingCopied {
                Label("Copied", systemImage: "doc.on.doc.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: Capsule())
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sensoryFeedback(.success, trigger: copiedTrigger)
        .sensoryFeedback(.selection, trigger: feed.current)
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(greetingText)
                .font(.title.bold())
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let salutation = switch hour {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
        if let name = user.firstName { return "\(salutation), \(name)" }
        return salutation
    }

    private var actions: some View {
        HStack(spacing: 12) {
            ActionButton(title: "Back", systemImage: "arrow.uturn.backward") {
                feed.goBack()
            }
            .disabled(!feed.canGoBack)

            ActionButton(title: isFavorite ? "Saved" : "Save", systemImage: isFavorite ? "heart.fill" : "heart") {
                modelContext.toggleFavorite(feed.current, for: user.id)
            }
            .sensoryFeedback(.impact, trigger: isFavorite)

            ActionButton(title: "Copy", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = feed.current.shareText
                copiedTrigger += 1
                showCopiedToast()
            }

            ShareLink(item: feed.current.shareText) {
                ActionLabel(title: "Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.plain)
        }
    }

    private func showCopiedToast() {
        withAnimation { isShowingCopied = true }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation { isShowingCopied = false }
        }
    }
}

private struct ActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ActionLabel(title: title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
    }
}

private struct ActionLabel: View {
    let title: String
    let systemImage: String
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .contentTransition(.symbolEffect(.replace))
            Text(title)
                .font(.caption.weight(.medium))
        }
        .frame(maxWidth: .infinity, minHeight: 64)
        .foregroundStyle(isEnabled ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
        .cardSurface(cornerRadius: 16)
    }
}

#Preview {
    NavigationStack {
        QuoteHomeView(user: .preview, repository: .offline)
    }
    .modelContainer(for: FavoriteQuote.self, inMemory: true)
}
