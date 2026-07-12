import SwiftUI

struct SignupView: View {

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""

    @State private var showPassword = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    @Environment(\.dismiss) private var dismiss

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.yellow.opacity(0.95),
                Color.orange.opacity(0.75),
                Color.yellow.opacity(0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {

        ZStack {

            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 70))
                    .foregroundStyle(.blue)

                Text("Don't have an account")
                    .font(.title)
                    .fontWeight(.bold)

                Text("No Worries!")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)

                // MARK: Full Name

                Text("Full Name")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {

                    Image(systemName: "person.fill")
                        .foregroundStyle(.gray)

                    TextField("Enter your Name", text: $fullName)
                        .autocorrectionDisabled()
                }
                .padding(.vertical,16)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(15)

                // MARK: Email

                Text("Email")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {

                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.gray)

                    TextField("Enter your Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.vertical,16)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(15)

                // MARK: Password

                Text("Password")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {

                    Image(systemName: "lock.fill")
                        .foregroundStyle(.gray)

                    if showPassword {

                        TextField("Enter your Password", text: $password)

                    } else {

                        SecureField("Enter your Password", text: $password)

                    }

                    Button {

                        showPassword.toggle()

                    } label: {

                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")

                    }

                }
                .padding(.vertical,16)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(15)

                if !errorMessage.isEmpty {

                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.subheadline)

                }

                // MARK: Create Account

                Button {

                    signUp()

                } label: {

                    HStack {

                        if isLoading {

                            ProgressView()
                                .tint(.white)

                            Text("Creating Account...")

                        } else {

                            Image(systemName: "lock.fill")

                            Text("Create Account")

                            Spacer()

                            Image(systemName: "arrow.right")

                        }

                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .font(.system(size:20))
                    .cornerRadius(15)

                }
                .disabled(isLoading)

                Spacer()
                    .frame(height:10)

                HStack {

                    Text("Already have an account.")

                    NavigationLink {

                        LoginView()

                    } label: {

                        Text("Login")
                            .foregroundStyle(.blue)
                            .fontWeight(.bold)

                    }

                }

            }
            .padding(.horizontal,25)

        }

        .toolbarBackground(.hidden, for: .navigationBar)

    }

    // MARK: Firebase Signup

    func signUp() {

        errorMessage = ""

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if fullName.isEmpty {

            errorMessage = "Please enter your Full Name"
            return

        }

        if cleanEmail.isEmpty {

            errorMessage = "Please enter your Email"
            return

        }

        if !cleanEmail.contains("@") || !cleanEmail.contains(".") {

            errorMessage = "Please enter a valid Email"
            return

        }

        if password.isEmpty {

            errorMessage = "Please enter your Password"
            return

        }

        if password.count < 6 {

            errorMessage = "Password must be at least 6 characters"
            return

        }

        isLoading = true

        FirebaseAuthService.shared.signUp(
            email: cleanEmail,
            password: password
        ) { result in

            DispatchQueue.main.async {

                isLoading = false

                switch result {

                case .success(_):

                    dismiss()

                case .failure(let error):

                    errorMessage = error.localizedDescription

                }

            }

        }

    }

}
