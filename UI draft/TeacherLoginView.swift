//
//  TeacherLoginView.swift
//  UI draft
//

import SwiftUI

struct TeacherLoginView: View {

    @State private var email = ""
    @State private var password = ""
    @StateObject private var auth = AuthenticationManager()

    var body: some View {

        NavigationStack {
            VStack(spacing: 25) {

                Spacer()

                Image(systemName: "person.badge.key.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)

                Text("Teacher Login")
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
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button {
                    auth.signIn(email: email, password: password)
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                if !auth.errorMessage.isEmpty {
                    Text(auth.errorMessage)
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $auth.isLoggedIn) {
                ContentView()
            }
        }

    }
}

#Preview {
    TeacherLoginView()
}
