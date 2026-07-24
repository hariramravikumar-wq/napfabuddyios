import Foundation
import FirebaseFirestore

class FirestoreManager {

    static let shared = FirestoreManager()

    private let db = Firestore.firestore()

    func saveStudent(_ student: Student) {

        let data: [String: Any] = [
            "id": student.id,
            "name": student.name,
            "studentClass": student.studentClass,
            "sitUps": student.sitUps ?? "",
            "pushUps": student.pushUps ?? "",
            "pullUps": student.pullUps ?? "",
            "shuttleRun": student.shuttleRun ?? "",
            "standingBroadJump": student.standingBroadJump ?? "",
            "run24km": student.run24km ?? "",
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("results").document(student.id).setData(data) { error in
            if let error = error {
                print("❌ Firestore Error: \(error.localizedDescription)")
            } else {
                print("✅ Student saved successfully!")
            }
        }
    }
}
