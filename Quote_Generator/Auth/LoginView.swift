import SwiftUI
import QuoteKit

struct LoginView: View {
    @Environment(SessionModel.self) private var session

    @State private var email = ""
    @State private var password = ""
    @State private var isShowingReset = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header

                VStack(spacing: 16) {
                    FormField(title: "Email", systemImage: "envelope.fill", text: $email, prompt: "you@example.com", contentType: .username, keyboard: .emailAddress)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                    FormField(title: "Password", systemImage: "lock.fill", text: $password, prompt: "Your password", isSecure: true, contentType: .password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit(signIn)

                    HStack {
                        Spacer()
                        Button("Forgot password?") { isShowingReset = true }
                            .font(.footnote.weight(.semibold))
                    }

                    if let error = session.errorMessage {
                        StatusMessage(text: error, kind: .error)
                    }

                    PrimaryButton(title: "Sign In", isLoading: session.isWorking, action: signIn)
                }
                .padding(20)
                .cardSurface()

                VStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Text("New here?")
                        NavigationLink("Create an account") {
                            SignupView()
                        }
                        .fontWeight(.semibold)
                    }

                    Button("Continue without an account") {
                        session.continueAsGuest()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
            .animation(.default, value: session.errorMessage)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(GradientBackground())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { session.clearMessages() }
        .sheet(isPresented: $isShowingReset) {
            ForgotPasswordView(initialEmail: email)
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "quote.opening")
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text("Welcome back")
                .font(.largeTitle.bold())
            Text("Your daily dose of inspiration is waiting.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 24)
    }

    private func signIn() {
        focusedField = nil
        Task { await session.signIn(email: email, password: password) }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environment(SessionModel.preview())
}
