import SwiftUI
import FirebaseFirestore

struct AddStudentView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var studentClass = ""
    @State private var message = ""
    @State private var showSuccess = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.8), .cyan.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 75))
                        .foregroundColor(.white)
                    
                    Text("Add Student")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    VStack(spacing: 18) {
                        TextField("Student Name", text: $name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .textInputAutocapitalization(.words)
                        
                        TextField("Class (Example: 2E)", text: $studentClass)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            
                        Button {
                            addStudent()
                        } label: {
                            Text("Save Student")
                                .font(.headline)
                                .frame(width: 220)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    .padding(25)
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                    
                    Text(message)
                        .foregroundColor(.white)
                        .bold()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Student")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
            }
        }
    }
    
    func addStudent() {
        guard !name.isEmpty, !studentClass.isEmpty else {
            message = "Please fill in all fields"
            return
        }
        
        let data: [String: Any] = [
            "name": name,
            "studentClass": studentClass,
            "sitUps": "",
            "pushUps": "",
            "pullUps": "",
            "shuttleRun": "",
            "standingBroadJump": "",
            "sitAndReach": "",
            "run24km": ""
        ]
        
        db.collection("students").addDocument(data: data) { error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
            } else {
                message = "Student added successfully ✅"
                showSuccess = true
            }
        }
    }
}
