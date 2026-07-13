import SwiftUI

struct CreateTeacherAccountView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var auth = AuthenticationManager()

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showSuccessAlert = false

    var body: some View {

        NavigationStack {

            VStack(spacing: 20) {

                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)

                Text("Create Teacher Account")
                    .font(.largeTitle)
                    .bold()

                TextField("MOE Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button("Create Account") {

                    guard password == confirmPassword else {
                        auth.errorMessage = "Passwords do not match."
                        return
                    }

                    auth.errorMessage = ""
                    auth.createTeacherAccount(
                        email: email,
                        password: password
                    )
                    Task {
                        while true {
                            try? await Task.sleep(for: .milliseconds(150))
                            await MainActor.run {
                                if auth.isLoggedIn {
                                    showSuccessAlert = true
                                }
                            }
                            if await MainActor.run(body: { auth.isLoggedIn || !auth.errorMessage.isEmpty }) {
                                break
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)

                if !auth.errorMessage.isEmpty {

                    Text(auth.errorMessage)
                        .foregroundColor(.red)

                }

                Spacer()

            }
            .padding()
            .navigationTitle("Teacher Sign Up")
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                email = ""
                password = ""
                confirmPassword = ""
                auth.errorMessage = ""
                dismiss()
            }
        } message: {
            Text("Account successfully created!")
        }
    }
}

#Preview {
    CreateTeacherAccountView()
}
