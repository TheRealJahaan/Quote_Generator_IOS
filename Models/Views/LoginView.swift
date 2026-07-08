import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var errorMessage = ""
    @State private var navigateToQuote = false

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.yellow.opacity(0.95), Color.orange.opacity(0.75), Color.yellow.opacity(0.35)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea(.all)

            NavigationStack {
                VStack(spacing: 24) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.blue)

                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Read your daily inspiration")
                        .foregroundStyle(.gray)

                    Text("Email")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.gray)

                        TextField("Enter your email", text: $email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .font(.headline)
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(15)

                    Text("Password")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.gray)

                        if showPassword {
                            TextField("Enter your Password", text: $password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("Enter your Password", text: $password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }

                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        }
                    }
                    .font(.headline)
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(15)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.subheadline)
                    }

                    Button {
                        if email.isEmpty {
                            errorMessage = "Please Enter Your Email"
                        } else if !email.contains("@") || !email.contains(".") {
                            errorMessage = "Please Enter a Valid Email"
                        } else if password.isEmpty {
                            errorMessage = "Please Enter Your Password"
                        } else if AuthService.shared.login(email: email, password: password){
                            errorMessage = ""
                            navigateToQuote = true
                        }
                        else{
                            errorMessage = "Invalid email or password"
                        }
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: "lock.fill")
                            Text("Login")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.system(size: 20))
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(15)
                    }

                    Spacer()
                        .frame(height: 10)

                    HStack {
                        Text("Don't have an account")

                        NavigationLink {
                            SignupView()
                        } label: {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundGradient.ignoresSafeArea(.all))
                .navigationDestination(isPresented: $navigateToQuote) {
                    QuoteView()
                }
                .toolbarBackground(.hidden, for: .navigationBar)
            }
            .background(Color.clear)
        }
        .background(backgroundGradient.ignoresSafeArea(.all))
    }
}

#Preview {
    LoginView()
}
