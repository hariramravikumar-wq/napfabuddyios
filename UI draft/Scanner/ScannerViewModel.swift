import Foundation
import SwiftUI
import Combine

@MainActor
class ScannerViewModel: ObservableObject {

    @Published var scannedStudent: Student?
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var uploadSuccessful = false

    func processQRCode(_ qrText: String) {

        // QR Format:
        // Name|Class|ShuttleRun|SitUps|PushUps|StandingBroadJump|2.4km

        let components = qrText.components(separatedBy: "|")

        guard components.count == 7 else {
            errorMessage = "Invalid QR Code."
            showError = true
            return
        }

        let student = Student(
            id: UUID().uuidString,
            name: components[0],
            studentClass: components[1],
            sitUps: components[3],
            pushUps: components[4],
            pullUps: nil,
            shuttleRun: components[2],
            standingBroadJump: components[5],
            run24km: components[6]
        )

        scannedStudent = student

        FirestoreManager.shared.saveStudent(student)

        uploadSuccessful = true
    }

    func reset() {
        scannedStudent = nil
        uploadSuccessful = false
        errorMessage = ""
        showError = false
    }
}
