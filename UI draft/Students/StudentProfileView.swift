//
//  StudentProfileView.swift
//  UI draft
//
//  Created by Rayson Ng on 13/7/26.
//

import SwiftUI
import FirebaseFirestore

struct ActivityLog: Identifiable {
    let id: String
    let station: String
    let score: String
    let recordedAt: Date?
}

private extension DateFormatter {
    static let activityLogFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
}

struct StudentProfileView: View {
    
    let student: Student
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var latestScores: [String: (score: String, unit: String)] = [:]
    @State private var activityLogs: [ActivityLog] = []
    
    private let db = Firestore.firestore()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())

                    Image(systemName: "person.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                }
                .shadow(radius: 8)

                Text(student.name)
                    .font(.largeTitle)
                    .bold()

                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Class", systemImage: "graduationcap.fill")
                            .font(.headline)
                        Text(student.studentClass)

                        if let dob = student.dateOfBirth, !dob.isEmpty {
                            Divider()
                            Label("Date of Birth", systemImage: "calendar")
                                .font(.headline)
                            Text(dob)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 2)

                    VStack(spacing: 15) {
                        Text("Student QR Code")
                            .font(.headline)

                        Image(uiImage: QRCodeGenerator.generate(from: student.id))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)

                        Text(student.id)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button {
                            UIPasteboard.general.string = student.id
                        } label: {
                            Label("Copy Student ID", systemImage: "doc.on.doc")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 2)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Latest Scores")
                        .font(.headline)

                    if latestScores.isEmpty {
                        Label("No latest scores yet.", systemImage: "chart.bar.doc.horizontal")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(latestScores.keys.sorted(), id: \.self) { station in
                            let entry = latestScores[station]
                            HStack {
                                Text(station)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(entry?.score ?? "-") \(entry?.unit ?? "")")
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Divider().padding(.vertical, 6)

                    Text("Activity Log")
                        .font(.headline)

                    if activityLogs.isEmpty {
                        Label("No activity yet.", systemImage: "clock")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(activityLogs) { log in
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(log.station)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Text(log.score)
                                            .font(.body)
                                            .foregroundColor(.blue)
                                    }
                                    Spacer()
                                    Text(log.recordedAt.map { DateFormatter.activityLogFormatter.string(from: $0) } ?? "-")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)

                Button {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete Student", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(isDeleting)
            }

            Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Student Profile")
        .onAppear {
            loadLatestScores()
            loadActivityLogs()
        }
        .confirmationDialog(
            "Delete \(student.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Student", role: .destructive) {
                deleteStudent()
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove the student from Firebase. This action cannot be undone.")
        }
    }

    private func loadLatestScores() {
        db.collection("students")
            .document(student.id)
            .collection("scores")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else { return }
                var map: [String: (score: String, unit: String)] = [:]
                for doc in docs {
                    let data = doc.data()
                    let station = data["station"] as? String ?? doc.documentID
                    let score = data["score"] as? String ?? ""
                    let unit = data["unit"] as? String ?? ""
                    map[station] = (score: score, unit: unit)
                }
                DispatchQueue.main.async {
                    self.latestScores = map
                }
            }
    }

    private func loadActivityLogs() {
        db.collection("students")
            .document(student.id)
            .collection("activityLogs")
            .order(by: "recordedAt", descending: true)
            .limit(to: 50)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else { return }
                let logs: [ActivityLog] = docs.map { doc in
                    let data = doc.data()
                    let station = data["station"] as? String ?? "-"
                    let score = data["score"] as? String ?? "-"
                    let ts = data["recordedAt"] as? Timestamp
                    return ActivityLog(
                        id: doc.documentID,
                        station: station,
                        score: score,
                        recordedAt: ts?.dateValue()
                    )
                }
                DispatchQueue.main.async {
                    self.activityLogs = logs
                }
            }
    }

    private func deleteStudent() {
        isDeleting = true

        db.collection("students")
            .document(student.id)
            .delete { error in
                DispatchQueue.main.async {
                    isDeleting = false

                    if let error = error {
                        print("Failed to delete student:", error.localizedDescription)
                    } else {
                        print("Student deleted successfully")
                        dismiss()
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        StudentProfileView(
            student: Student(
                id: "STU-001",
                name: "John Tan",
                studentClass: "2E1",
                dateOfBirth: "16 Apr 2012",
                gender: "Male",
                height: "165",
                weight: "52",
                qrCodeString: "STU-001",
                sitUps: nil,
                pushUps: nil,
                pullUps: nil,
                shuttleRun: nil,
                standingBroadJump: nil,
                sitAndReach: nil,
                run24km: nil
            )
        )
    }
}
