import SwiftUI
import UIKit
import SwiftData
import QuoteKit

struct FavoritesView: View {
    let user: AppUser

    @Query private var favorites: [FavoriteQuote]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""

    init(user: AppUser) {
        self.user = user
        let userID = user.id
        _favorites = Query(
            filter: #Predicate<FavoriteQuote> { $0.userID == userID },
            sort: \FavoriteQuote.savedAt,
            order: .reverse
        )
    }

    private var filtered: [FavoriteQuote] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return favorites }
        return favorites.filter {
            $0.text.localizedCaseInsensitiveContains(query) || $0.author.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        Group {
            if favorites.isEmpty {
                ContentUnavailableView(
                    "No favorites yet",
                    systemImage: "heart",
                    description: Text("Tap Save on a quote you love and it will show up here.")
                )
            } else if filtered.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List {
                    ForEach(filtered) { favorite in
                        FavoriteRow(favorite: favorite)
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelContext.delete(favorite)
                                } label: {
                                    Label("Remove", systemImage: "heart.slash")
                                }
                            }
                            .contextMenu {
                                ShareLink(item: favorite.quote.shareText)
                                Button {
                                    UIPasteboard.general.string = favorite.quote.shareText
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                Button(role: .destructive) {
                                    modelContext.delete(favorite)
                                } label: {
                                    Label("Remove", systemImage: "heart.slash")
                                }
                            }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(GradientBackground())
        .navigationTitle("Favorites")
        .searchable(text: $searchText, prompt: "Search quotes or authors")
    }
}

private struct FavoriteRow: View {
    let favorite: FavoriteQuote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(favorite.text)
                .font(.system(.body, design: .serif))
            HStack {
                Text(favorite.author)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tint)
                Spacer()
                Text(favorite.savedAt, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let container = try! ModelContainer(for: FavoriteQuote.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    for quote in BundledQuotes.all.prefix(4) {
        container.mainContext.insert(FavoriteQuote(userID: AppUser.preview.id, quote: quote))
    }
    return NavigationStack {
        FavoritesView(user: .preview)
    }
    .modelContainer(container)
}
