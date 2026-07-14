//
//  TeacherLoginView.swift
//  UI draft
//

import SwiftUI

struct TeacherLoginView: View {

    @Environment(\.dismiss) private var dismiss

    @ObservedObject var auth: AuthenticationManager

    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    @State private var showTeacherHome = false
    @State private var showAdminHome = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)

                    Text("Teacher Login")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)

                    Text("Sign in with your MOE account")
                        .foregroundColor(.white.opacity(0.9))

                    VStack(spacing: 16) {
                        TextField("MOE Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .focused($focusedField, equals: .email)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .focused($focusedField, equals: .password)

                        Button {
                            auth.signIn(email: email, password: password)
                        } label: {
                            Text("Login")
                                .font(.headline)
                                .frame(width: 220)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    .padding(25)
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)

                    if !auth.errorMessage.isEmpty {
                        Text(auth.errorMessage)
                            .foregroundColor(.white)
                            .bold()
                    }

                    NavigationLink(isActive: $showTeacherHome) {
                        ContentView(auth: auth)
                    } label: {
                        EmptyView()
                    }

                    NavigationLink(isActive: $showAdminHome) {
                        ManageTeachersView()
                    } label: {
                        EmptyView()
                    }

                    Spacer()
                }
                .padding()
            }
            .onAppear {
                focusedField = .email
            }
            .onChange(of: auth.isLoggedIn) { loggedIn in
                if loggedIn {
                    if auth.isAdmin {
                        showAdminHome = true
                    } else {
                        showTeacherHome = true
                    }
                }
            }
        }
    }
}

#Preview {
    TeacherLoginView(auth: AuthenticationManager())
}
