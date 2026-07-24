import SwiftUI
import FirebaseFirestore

struct TeacherDetailView: View {
    
    let teacher: Teacher
    private let db = Firestore.firestore()
    
    @State private var isActive: Bool
    @State private var role: String
    
    init(teacher: Teacher) {
        self.teacher = teacher
        _isActive = State(initialValue: teacher.isActive)
        _role = State(initialValue: teacher.role)
    }
    
    var body: some View {
        VStack(spacing: 25) {
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 90))
                .foregroundColor(.blue)
            
            Text(teacher.displayName)
                .font(.largeTitle)
                .bold()
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Email")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(teacher.email)
                
                Divider()
                
                Text("Role")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(role.capitalized)
                
                Divider()
                
                Text("Status")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(isActive ? "Active" : "Disabled")
                    .foregroundColor(isActive ? .green : .red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Button {
                toggleRole()
            } label: {
                Label(role == "admin" ? "Remove Admin" : "Make Admin", systemImage: "star.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Button {
                toggleActive()
            } label: {
                Label(isActive ? "Disable Account" : "Enable Account", systemImage: "person.crop.circle.badge.minus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isActive ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Button(role: .destructive) {
                deleteTeacher()
            } label: {
                Label("Delete Teacher", systemImage: "trash")
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Teacher Details")
    }
    
    func toggleRole() {
        let newRole = role == "admin" ? "teacher" : "admin"
        db.collection("teachers").document(teacher.id).updateData(["role": newRole])
        role = newRole
    }
    
    func toggleActive() {
        let newStatus = !isActive
        db.collection("teachers").document(teacher.id).updateData(["isActive": newStatus])
        isActive = newStatus
    }
    
    func deleteTeacher() {
        db.collection("teachers").document(teacher.id).delete()
    }
}
