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
    @Published var isAdmin = false
    @Published var teacherName = ""
    @Published var teacherRole = ""

    var role: String {
        teacherRole
    }

    private let db = Firestore.firestore()

    // MARK: - Sign In

    func signIn(email: String, password: String) {

        guard email.lowercased().hasSuffix("@moe.edu.sg") else {
            errorMessage = "Only MOE teacher email addresses are allowed."
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            Task { @MainActor in

                guard let self else { return }

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let user = result?.user else {
                    self.errorMessage = "Unable to sign in."
                    return
                }

                do {
                    let snapshot = try await self.db.collection("teachers")
                        .document(user.uid)
                        .getDocument()

                    guard let data = snapshot.data() else {
                        self.errorMessage = "Teacher profile not found."
                        try? Auth.auth().signOut()
                        return
                    }

                    let active = data["isActive"] as? Bool ?? false
                    if !active {
                        self.errorMessage = "This teacher account has been disabled."
                        try? Auth.auth().signOut()
                        return
                    }

                    self.teacherRole = data["role"] as? String ?? "teacher"
                    self.teacherName = data["displayName"] as? String ?? ""
                    self.isAdmin = (self.teacherRole == "admin")

                    try await self.db.collection("teachers")
                        .document(user.uid)
                        .updateData([
                            "lastLogin": Timestamp()
                        ])
                } catch {
                    // Non-fatal: we still log the user in, but record the error
                    self.errorMessage = error.localizedDescription
                }

                self.isLoggedIn = true
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
            Task { @MainActor in

                guard let self else { return }

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let user = result?.user else {
                    self.errorMessage = "Unable to create account."
                    return
                }

                let teacherData: [String: Any] = [
                    "email": email,
                    "displayName": email.components(separatedBy: "@").first ?? "",
                    "role": "teacher",
                    "isActive": true,
                    "createdAt": Timestamp(),
                    "lastLogin": Timestamp()
                ]

                do {
                    try await self.db.collection("teachers")
                        .document(user.uid)
                        .setData(teacherData)
                    self.isLoggedIn = true
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Check Role

    func fetchTeacherRole(
        completion: @escaping (String?) -> Void
    ) {

        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        db.collection("teachers")
            .document(uid)
            .getDocument { snapshot, error in

                guard
                    error == nil,
                    let data = snapshot?.data()
                else {
                    completion(nil)
                    return
                }

                completion(data["role"] as? String)
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
