import SwiftUI
import FirebaseFirestore

struct ManageStudentsView: View {
    @ObservedObject var auth: AuthenticationManager
    @State private var students: [Student] = []
    @State private var showAddStudent = false
    @State private var searchText = ""
    
    private let db = Firestore.firestore()
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return students
        }
        return students.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.studentClass.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(filteredStudents) { student in
                    NavigationLink {
                        StudentProfileView(student: student)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(student.name)
                                .font(.headline)
                            Text(student.studentClass)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .refreshable {
                loadStudents()
            }
        }
        .navigationTitle("Manage Students")
        .toolbar {
            Button {
                loadStudents()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            Button {
                showAddStudent = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddStudent, onDismiss: {
            loadStudents()
        }) {
            NavigationStack {
                AddStudentView()
            }
        }
        .onAppear {
            loadStudents()
        }
    }
    
    func loadStudents() {
        db.collection("students").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            students = documents.map { document in
                let data = document.data()
                // TODO: Add dateOfBirth, gender, qrCodeString to Student model if not present
                return Student(
                    id: document.documentID,
                    name: data["name"] as? String ?? "Unknown",
                    studentClass: data["studentClass"] as? String ?? "-",
                    sitUps: data["sitUps"] as? String,
                    pushUps: data["pushUps"] as? String,
                    pullUps: data["pullUps"] as? String,
                    shuttleRun: data["shuttleRun"] as? String,
                    standingBroadJump: data["standingBroadJump"] as? String,
                    sitAndReach: data["sitAndReach"] as? String,
                    run24km: data["run24km"] as? String
                )
            }
        }
    }
}
