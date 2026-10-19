import SwiftUI
import QuoteKit

struct SignupView: View {
    @Environment(SessionModel.self) private var session

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmation = ""
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, email, password, confirmation
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 52))
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                    Text("Create your account")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text("Save the quotes that move you.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    FormField(title: "Name", systemImage: "person.fill", text: $name, prompt: "Your name", contentType: .name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }

                    FormField(title: "Email", systemImage: "envelope.fill", text: $email, prompt: "you@example.com", contentType: .username, keyboard: .emailAddress)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                    FormField(title: "Password", systemImage: "lock.fill", text: $password, prompt: "At least \(CredentialValidator.minimumPasswordLength) characters", isSecure: true, contentType: .newPassword)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .confirmation }

                    FormField(title: "Confirm password", systemImage: "lock.rotation", text: $confirmation, prompt: "Type it again", isSecure: true, contentType: .newPassword)
                        .focused($focusedField, equals: .confirmation)
                        .submitLabel(.join)
                        .onSubmit(signUp)

                    Text("Use \(CredentialValidator.minimumPasswordLength)+ characters with at least one letter and one number.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let error = session.errorMessage {
                        StatusMessage(text: error, kind: .error)
                    }

                    PrimaryButton(title: "Create Account", systemImage: "sparkles", isLoading: session.isWorking, action: signUp)
                }
                .padding(20)
                .cardSurface()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
            .animation(.default, value: session.errorMessage)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(GradientBackground())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { session.clearMessages() }
    }

    private func signUp() {
        focusedField = nil
        Task { await session.signUp(name: name, email: email, password: password, confirmation: confirmation) }
    }
}

#Preview {
    NavigationStack {
        SignupView()
    }
    .environment(SessionModel.preview())
}
