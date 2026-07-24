import SwiftUI
import FirebaseFirestore

struct Teacher: Identifiable {
    let id: String
    let displayName: String
    let email: String
    let role: String
    let isActive: Bool
}

struct ManageTeachersView: View {
    @ObservedObject var auth: AuthenticationManager
    @State private var teachers: [Teacher] = []
    @State private var isLoading = true

    private let db = Firestore.firestore()
    @State private var showCreateTeacher = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)

                Text("Manage Teachers")
                    .font(.largeTitle)
                    .bold()

                Text("Only administrators can create and manage teacher accounts.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                if isLoading {
                    ProgressView("Loading teachers...")
                } else {
                    List(teachers) { teacher in
                        NavigationLink {
                            TeacherDetailView(teacher: teacher)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(teacher.displayName)
                                        .font(.headline)
                                    Text(teacher.email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(teacher.role.capitalized)
                                    .font(.caption)
                                    .padding(6)
                                    .background(teacher.role == "admin" ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .frame(height: 300)
                }

                NavigationLink {
                    ContentView(auth: auth)
                } label: {
                    Label("Teacher Dashboard", systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                NavigationLink {
                    ManageStudentsView(auth: AuthenticationManager())
                } label: {
                    Label("Manage Students", systemImage: "person.2.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button {
                    showCreateTeacher = true
                } label: {
                    Label("Add Teacher", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Admin")
            .onAppear {
                db.collection("teachers").getDocuments { snapshot, error in
                    guard let docs = snapshot?.documents else {
                        isLoading = false
                        return
                    }

                    teachers = docs.map { doc in
                        let data = doc.data()
                        return Teacher(
                            id: doc.documentID,
                            displayName: data["displayName"] as? String ?? "Unknown",
                            email: data["email"] as? String ?? "",
                            role: data["role"] as? String ?? "teacher",
                            isActive: data["isActive"] as? Bool ?? true
                        )
                    }
                    isLoading = false
                }
            }
            .sheet(isPresented: $showCreateTeacher) {
                CreateTeacherAccountView()
            }
        }
    }
}

#Preview {
    ManageTeachersView(auth: AuthenticationManager())
}
