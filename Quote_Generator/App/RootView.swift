import SwiftUI
import SwiftData
import QuoteKit

/// Chooses between the splash, sign-in flow and the main app based on the session.
struct RootView: View {
    @Environment(SessionModel.self) private var session

    var body: some View {
        Group {
            switch session.state {
            case .loading:
                SplashView()
            case .signedOut:
                NavigationStack {
                    LoginView()
                }
            case .signedIn(let user):
                MainTabView(user: user)
                    .id(user.id)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: session.state)
        .task {
            await session.observeAuthState()
        }
    }
}

private struct SplashView: View {
    var body: some View {
        ZStack {
            GradientBackground()
            VStack(spacing: 16) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.tint)
                ProgressView()
            }
        }
    }
}

struct MainTabView: View {
    let user: AppUser

    var body: some View {
        TabView {
            NavigationStack {
                QuoteHomeView(user: user)
            }
            .tabItem { Label("Today", systemImage: "sun.max.fill") }

            NavigationStack {
                FavoritesView(user: user)
            }
            .tabItem { Label("Favorites", systemImage: "heart.fill") }

            NavigationStack {
                SettingsView(user: user)
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

#Preview("Signed out") {
    RootView()
        .environment(SessionModel.preview())
        .modelContainer(for: FavoriteQuote.self, inMemory: true)
}

#Preview("Signed in") {
    RootView()
        .environment(SessionModel.preview(signedInAs: .preview))
        .modelContainer(for: FavoriteQuote.self, inMemory: true)
}
