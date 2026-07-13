//
//  AuthenticationManager.swift
//  UI draft
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationManager: ObservableObject {

    @Published var isLoggedIn = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    // MARK: - Sign In

    func signIn(email: String, password: String) {

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in

            DispatchQueue.main.async {

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                guard let user = result?.user else {
                    self?.errorMessage = "Unable to log in."
                    return
                }

                if !user.email!.lowercased().hasSuffix("@moe.edu.sg") {
                    self?.errorMessage = "Only MOE teachers may log in."

                    do {
                        try Auth.auth().signOut()
                    } catch { }

                    return
                }

                self?.isLoggedIn = true
            }
        }
    }

    // MARK: - Create Teacher Account

    func createTeacherAccount(
        email: String,
        password: String
    ) {

        guard email.lowercased().hasSuffix("@moe.edu.sg") else {

            errorMessage = "Email must end with @moe.edu.sg"

            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in

            DispatchQueue.main.async {

                if let error = error {

                    self?.errorMessage = error.localizedDescription
                    return
                }

                guard let uid = result?.user.uid else { return }

                self?.db.collection("teachers").document(uid).setData([

                    "email": email,
                    "role": "teacher",
                    "createdAt": Timestamp()

                ])

                self?.isLoggedIn = true
            }

        }

    }

    // MARK: - Logout

    func signOut() {

        do {

            try Auth.auth().signOut()

            isLoggedIn = false

        } catch {

            errorMessage = error.localizedDescription

        }

    }

}
