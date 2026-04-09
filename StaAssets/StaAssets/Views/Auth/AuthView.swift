import SwiftUI

struct AuthView: View {
    
    @State private var selectedTab = 0
    
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var confirmPassword = ""
    
    // MARK: - Validation States
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    @State private var fullNameError: String?
    
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var userVM: UserViewModel
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, fullName, confirmPassword
    }
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            GeometryReader { geo in
                
                VStack(spacing: selectedTab == 1 ? 16 : 28) {
                    
                    Spacer(minLength: selectedTab == 1 ? 10 : 40)
                    
                    // MARK: - Header (ANIMATED)
                    VStack(spacing: 14) {
                        
                        Image("appLogo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 55, height: 55)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text("Welcome to Cashify")
                            .font(.title2.bold())
                        
                        Text("Send money globally with the real exchange rate")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selectedTab)
                    
                    // MARK: - CARD
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("Get started")
                            .font(.headline)
                        
                        Text("Sign in to your account or create a new one")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Picker("", selection: $selectedTab) {
                            Text("Sign In").tag(0)
                            Text("Sign Up").tag(1)
                        }
                        .pickerStyle(.segmented)
                        
                        // MARK: - Fields (ANIMATED PROPERLY)
                        VStack(spacing: 14) {
                            
                            if selectedTab == 1 {
                                inputField("Full Name", text: $fullName, error: fullNameError)
                                    .focused($focusedField, equals: .fullName)
                                    .transition(fieldTransition)
                            }
                            
                            inputField("Email", text: $email, error: emailError)
                                .focused($focusedField, equals: .email)
                            
                            passwordField("Password", text: $password, error: passwordError)
                                .focused($focusedField, equals: .password)
                            
                            if selectedTab == 1 {
                                passwordField("Confirm Password", text: $confirmPassword, error: confirmPasswordError)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .transition(fieldTransition)
                            }
                        }
                        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
                        
                        // MARK: - Forgot Password
                        if selectedTab == 0 {
                            HStack {
                                Spacer()
                                Text("Forgot password?")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // MARK: - Button
                        Button {
                            
                            dismissKeyboard()
                            
                            if validateAll() {
                                
                                if selectedTab == 1 {
                                    userVM.name = fullName
                                    userVM.email = email
                                } else {
                                    userVM.email = email
                                    let nameFromEmail = email.split(separator: "@").first ?? "User"
                                    userVM.name = String(nameFromEmail).capitalized
                                }
                                
                                withAnimation {
                                    isLoggedIn = true
                                }
                            }
                            
                        } label: {
                            Text(selectedTab == 0 ? "Sign In" : "Create Account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.primary : Color.gray.opacity(0.4))
                                .foregroundStyle(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
                    
                    Spacer()
                }
                .padding()
                .frame(height: geo.size.height)
            }
        }
    }
}

// MARK: - Validation Logic

extension AuthView {
    
    var fieldTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: -10)),
            removal: .opacity.combined(with: .offset(y: 10))
        )
    }
    
    var isFormValid: Bool {
        if selectedTab == 0 {
            return isValidEmail(email) && password.count >= 6
        } else {
            return !fullName.isEmpty &&
                   isValidEmail(email) &&
                   password.count >= 6 &&
                   password == confirmPassword
        }
    }
    
    func validateAll() -> Bool {
        
        emailError = isValidEmail(email) ? nil : "Enter a valid email"
        
        passwordError = password.count >= 6 ? nil : "Minimum 6 characters required"
        
        if selectedTab == 1 {
            fullNameError = fullName.isEmpty ? "Full name required" : nil
            confirmPasswordError = password == confirmPassword ? nil : "Passwords do not match"
        }
        
        return emailError == nil &&
               passwordError == nil &&
               (selectedTab == 0 || (fullNameError == nil && confirmPasswordError == nil))
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let regex = #"^\S+@\S+\.\S+$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }
}

// MARK: - Components

extension AuthView {
    
    func inputField(_ title: String, text: Binding<String>, error: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("Enter your \(title.lowercased())", text: text)
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(error == nil ? Color.primary.opacity(0.12) : Color.red, lineWidth: 1)
                )
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    func passwordField(_ title: String, text: Binding<String>, error: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            SecureField("Enter your \(title.lowercased())", text: text)
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(error == nil ? Color.primary.opacity(0.12) : Color.red, lineWidth: 1)
                )
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#Preview {
    AuthView(isLoggedIn: .constant(false))
}
