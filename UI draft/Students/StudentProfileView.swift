//
//  StudentProfileView.swift
//  UI draft
//
//  Created by Rayson Ng on 13/7/26.
//


import SwiftUI
import FirebaseFirestore

struct StudentProfileView: View {
    
    let student: Student
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    
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
                    Text("NAPFA Records")
                        .font(.headline)

                    Label("No records have been recorded yet.", systemImage: "chart.bar.doc.horizontal")
                        .foregroundColor(.secondary)
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

    private func deleteStudent() {
        isDeleting = true

        let db = Firestore.firestore()

        db.collection("users")
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
