import SwiftUI
import FirebaseFirestore

@MainActor
struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var auth: AuthenticationManager

    init(auth: AuthenticationManager) {
        _auth = ObservedObject(wrappedValue: auth)
    }
    
    // Centralized activity logging for manual entries and QR scan results
    func logActivity(name: String,
                     studentID: String?,
                     station: String,
                     score: String) {
        let db = Firestore.firestore()

        // Ensure we have a valid studentID to attach the log under the specific student
        guard let studentID = studentID, !studentID.isEmpty else {
            print("Failed to log activity: missing studentID")
            return
        }

        let payload: [String: Any] = [
            "name": name,
            "station": station,
            "score": score,
            "recordedAt": FieldValue.serverTimestamp()
        ]

        db.collection("students")
            .document(studentID)
            .collection("activityLogs")
            .addDocument(data: payload) { error in
                if let error = error {
                    print("Failed to log activity: \(error.localizedDescription)")
                } else {
                    print("Activity logged for student \(studentID): \(name) — \(station): \(score)")
                }
            }
    }
    

    // Saves a result into top-level `results` collection, updates student summary, and logs the activity
    func saveResultToTopLevelResults(studentID: String?,
                                     studentName: String,
                                     station: String,
                                     score: String,
                                     recordedBy teacherName: String? = nil) {
        let db = Firestore.firestore()

        // Validate inputs
        guard let studentID = studentID, !studentID.isEmpty else {
            print("Failed to save result: missing studentID")
            return
        }
        guard !station.isEmpty, !score.isEmpty else {
            print("Failed to save result: station and score are required")
            return
        }

        // 1) Add an entry to the top-level `results` collection
        let resultPayload: [String: Any] = [
            "studentID": studentID,
            "studentName": studentName,
            "station": station,
            "score": score,
            "recordedBy": teacherName ?? auth.teacherName,
            "recordedAt": FieldValue.serverTimestamp()
        ]

        db.collection("results")
            .addDocument(data: resultPayload) { error in
                if let error = error {
                    print("Failed to save result to top-level results: \(error)")
                } else {
                    print("Saved result to top-level results for student \(studentID): \(station) = \(score)")
                }
            }

        // 2) Update student's summary fields so Manage Students can show latest
        let summaryUpdates: [String: Any] = [
            "latestScores.\(station)": score,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        db.collection("students")
            .document(studentID)
            .setData(summaryUpdates, merge: true) { error in
                if let error = error {
                    print("Failed to update student summary: \(error)")
                }
            }

        // 3) Also append into activityLogs for history
        logActivity(name: studentName, studentID: studentID, station: station, score: score)
    }
    

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Screenshot 2026-05-25 at 4.30.28 PM")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        Spacer().frame(height: 30)

                        Image(systemName: "clipboard.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.yellow)

                        Text("NAPFA Buddy")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.black)

                        Text("Teacher Dashboard")
                            .font(.title2)
                            .foregroundColor(.black.opacity(0.8))

                        VStack(spacing: 14) {
                            NavigationLink {
                                Scanner()
                            } label: {
                                Text("📷 Record NAPFA Scores")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 320)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(15)
                            }
                            .padding(.horizontal)

                            NavigationLink {
                                ManageStudentsView(auth: AuthenticationManager())
                            } label: {
                                Text("👨‍🎓 Manage Students")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 320)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(15)
                            }
                            .padding(.horizontal)

                            if auth.isAdmin {
                                NavigationLink {
                                    ManageTeachersView(auth: AuthenticationManager())
                                } label: {
                                    Text("👨‍🏫 Manage Teachers")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: 320)
                                        .padding()
                                        .background(Color.orange)
                                        .cornerRadius(15)
                                }
                                .padding(.horizontal)
                            }   
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Logged in as: \(auth.teacherName.isEmpty ? "Unknown Teacher" : auth.teacherName)")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("Role: \(auth.teacherRole.isEmpty ? "Unknown" : auth.teacherRole.capitalized)")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: 320, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.92))
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 10)

                        Spacer()

                        Button(action: {
                            auth.signOut()
                            dismiss()
                        }) {
                            Text("Sign Out")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(maxWidth: 320)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(auth: AuthenticationManager())
}
