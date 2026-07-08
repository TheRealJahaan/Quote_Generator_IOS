import SwiftUI

struct SignupView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""

    @State private var showPassword = false

    @State private var errorMessage = ""

    
    @Environment(\.dismiss) private var dismiss
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


                VStack(spacing: 24) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 70))
                        .foregroundStyle(.blue)

                    Text("Don't have an account")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("No Worries!")
                        .frame(maxWidth: .infinity)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Full Name")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        
                        Image(systemName: "person.fill")
                            .foregroundStyle(.gray)

                        TextField("Enter your Name", text: $fullName)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .font(.headline)
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(15)

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
                        print("User Registered")
                        if fullName.isEmpty{
                            errorMessage = "Please Enter your Full Name"
                        }
                        
                        else if email.isEmpty {
                            errorMessage = "Please Enter Your Email"
                        }
                        
                        else if !email.contains("@")   || !email.contains(".") {
                            errorMessage = "Please Enter a Valid Email"
                        }
                        
                        else if password.isEmpty {
                            errorMessage = "Please Enter Your Password"
                        }
                        else if AuthService.shared.emailExists(email){
                            errorMessage = "Account already exists"
                        }
                        else {

                            errorMessage = ""
                            
                            let user = User(name: fullName, email: email, password: password)
                            AuthService.shared.register(user: user)
                            print(AuthService.shared.getAllUsers())
                            
                            dismiss()
                            
                        }
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: "lock.fill")
                            Text("Create Account")
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
                        Text("Already have an account.")

                        NavigationLink {
                            LoginView()
                        } label: {
                            Text("Login")
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                .toolbarBackground(.hidden, for: .navigationBar)
            
           
        }
        
        
    }
}
