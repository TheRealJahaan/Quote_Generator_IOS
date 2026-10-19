import SwiftUI
import SwiftData
import QuoteKit

struct SettingsView: View {
    let user: AppUser

    @Environment(SessionModel.self) private var session
    @Environment(\.modelContext) private var modelContext
    @State private var isConfirmingSignOut = false
    @State private var isConfirmingDelete = false
    @State private var isConfirmingClear = false

    var body: some View {
        Form {
            Section("Account") {
                if user.isGuest {
                    Label("Browsing as a guest", systemImage: "person.crop.circle.badge.questionmark")
                    Text("Favorites are saved on this device only.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Sign in or create an account") {
                        session.signOut()
                    }
                } else {
                    LabeledContent("Name", value: user.displayName ?? "Not set")
                    LabeledContent("Email", value: user.email ?? "Not set")
                    Button("Sign Out") { isConfirmingSignOut = true }
                }
            }

            Section {
                Button("Clear All Favorites", role: .destructive) { isConfirmingClear = true }
                if !user.isGuest {
                    Button("Delete Account", role: .destructive) { isConfirmingDelete = true }
                        .disabled(session.isWorking)
                }
            } footer: {
                if !user.isGuest {
                    Text("Deleting your account permanently removes it and the favorites saved with it.")
                }
            }

            if let error = session.errorMessage {
                Section {
                    StatusMessage(text: error, kind: .error)
                }
            }

            Section("About") {
                LabeledContent("Version", value: Self.appVersion)
                Link(destination: URL(string: "https://github.com/TheRealJahaan/Quote_Generator_IOS")!) {
                    Label("Source code on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                Link(destination: URL(string: "https://dummyjson.com/docs/quotes")!) {
                    Label("Quotes provided by DummyJSON", systemImage: "quote.bubble")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(GradientBackground())
        .navigationTitle("Settings")
        .onAppear { session.clearMessages() }
        .confirmationDialog("Sign out of Inspire Me?", isPresented: $isConfirmingSignOut, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) { session.signOut() }
        }
        .confirmationDialog("Remove every saved quote?", isPresented: $isConfirmingClear, titleVisibility: .visible) {
            Button("Clear Favorites", role: .destructive) { modelContext.deleteFavorites(for: user.id) }
        }
        .alert("Delete your account?", isPresented: $isConfirmingDelete) {
            Button("Delete", role: .destructive, action: deleteAccount)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
    }

    private func deleteAccount() {
        let userID = user.id
        Task {
            if await session.deleteAccount() {
                modelContext.deleteFavorites(for: userID)
            }
        }
    }

    private static var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    NavigationStack {
        SettingsView(user: .preview)
    }
    .environment(SessionModel.preview(signedInAs: .preview))
    .modelContainer(for: FavoriteQuote.self, inMemory: true)
}
