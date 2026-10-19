import SwiftUI

/// The warm sunrise gradient behind every screen, tuned separately for light and dark mode.
struct GradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }

    private var colors: [Color] {
        colorScheme == .dark
            ? [Color(red: 0.11, green: 0.09, blue: 0.20), Color(red: 0.27, green: 0.13, blue: 0.10), Color(red: 0.10, green: 0.08, blue: 0.12)]
            : [Color.yellow.opacity(0.85), Color.orange.opacity(0.65), Color.yellow.opacity(0.30)]
    }
}

/// Frosted card surface used for forms and the quote card.
struct CardSurface: ViewModifier {
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
    }
}

extension View {
    func cardSurface(cornerRadius: CGFloat = 24) -> some View {
        modifier(CardSurface(cornerRadius: cornerRadius))
    }
}

/// Full-width, high-contrast call to action with a built-in loading state.
struct PrimaryButton: View {
    let title: String
    var systemImage: String = "arrow.right"
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                    Image(systemName: systemImage)
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(.white)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .accessibilityLabel(isLoading ? "\(title), in progress" : title)
    }
}

/// An inline error or success message under a form.
struct StatusMessage: View {
    enum Kind {
        case error, info
    }

    let text: String
    let kind: Kind

    var body: some View {
        Label(text, systemImage: kind == .error ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
            .font(.subheadline)
            .foregroundStyle(kind == .error ? Color.red : Color.green)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
