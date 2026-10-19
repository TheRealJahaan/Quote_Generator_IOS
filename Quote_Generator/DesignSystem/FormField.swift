import SwiftUI
import UIKit

/// A labelled text or password field with an icon and, for passwords, a show/hide toggle.
struct FormField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    var prompt: String = ""
    var isSecure = false
    var contentType: UITextContentType?
    var keyboard: UIKeyboardType = .default

    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                    .accessibilityHidden(true)

                Group {
                    if isSecure && !isRevealed {
                        SecureField(prompt, text: $text)
                    } else {
                        TextField(prompt, text: $text)
                    }
                }
                .textContentType(contentType)
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress || isSecure ? .never : .words)
                .autocorrectionDisabled()
                .accessibilityLabel(title)

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
                }
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 50)
            .background(Color(.secondarySystemBackground).opacity(0.8), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
