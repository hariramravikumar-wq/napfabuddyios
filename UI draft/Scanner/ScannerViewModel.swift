import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class ScannerViewModel: ObservableObject {

    @Published var scannedStudent: Student?
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var uploadSuccessful = false

    func processQRCode(_ qrText: String) {

        let studentID = qrText.trimmingCharacters(in: .whitespacesAndNewlines)

        Firestore.firestore()
            .collection("students")
            .document(studentID)
            .getDocument { [weak self] snapshot, error in

                guard let self else { return }

                DispatchQueue.main.async {

                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                        return
                    }

                    guard
                        let snapshot = snapshot,
                        snapshot.exists,
                        let data = snapshot.data()
                    else {
                        self.errorMessage = "Student not found."
                        self.showError = true
                        return
                    }

                    let student = Student(
                        id: snapshot.documentID,
                        name: data["name"] as? String ?? "",
                        studentClass: data["studentClass"] as? String ?? "",
                        dateOfBirth: data["dateOfBirth"] as? String,
                        gender: data["gender"] as? String,
                        height: data["height"] as? String,
                        weight: data["weight"] as? String,
                        qrCodeString: snapshot.documentID,
                        sitUps: data["sitUps"] as? String,
                        pushUps: data["pushUps"] as? String,
                        pullUps: data["pullUps"] as? String,
                        shuttleRun: data["shuttleRun"] as? String,
                        standingBroadJump: data["standingBroadJump"] as? String,
                        sitAndReach: data["sitAndReach"] as? String,
                        run24km: data["run24km"] as? String
                    )

                    self.scannedStudent = student
                    self.uploadSuccessful = true
                }
            }
    }

    func reset() {
        scannedStudent = nil
        uploadSuccessful = false
        errorMessage = ""
        showError = false
    }
}
