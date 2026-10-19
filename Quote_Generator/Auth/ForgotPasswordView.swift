import SwiftUI
import QuoteKit

struct ForgotPasswordView: View {
    @Environment(SessionModel.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var email: String

    init(initialEmail: String = "") {
        _email = State(initialValue: initialEmail)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Enter the email you signed up with and we'll send you a link to choose a new password.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                FormField(title: "Email", systemImage: "envelope.fill", text: $email, prompt: "you@example.com", contentType: .username, keyboard: .emailAddress)
                    .submitLabel(.send)
                    .onSubmit(send)

                if let error = session.errorMessage {
                    StatusMessage(text: error, kind: .error)
                }
                if let info = session.infoMessage {
                    StatusMessage(text: info, kind: .info)
                }

                PrimaryButton(title: "Send Reset Link", systemImage: "paperplane.fill", isLoading: session.isWorking, action: send)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .animation(.default, value: session.infoMessage)
        }
        .presentationDetents([.medium, .large])
        .onAppear { session.clearMessages() }
        .onDisappear { session.clearMessages() }
    }

    private func send() {
        Task { await session.sendPasswordReset(email: email) }
    }
}

#Preview {
    ForgotPasswordView(initialEmail: "jahaan@example.com")
        .environment(SessionModel.preview())
}
