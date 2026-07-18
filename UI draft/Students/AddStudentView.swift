import SwiftUI
import FirebaseFirestore

struct AddStudentView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var studentClass = ""
    @State private var includeDateOfBirth = false
    @State private var dateOfBirth = Date()
    @State private var message = ""
    @State private var showSuccess = false
    @State private var createdStudentID = ""
    @State private var showQRCode = false
    @State private var showSuccessAlert = false
    
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
                        
                        Toggle("Add Date of Birth", isOn: $includeDateOfBirth)
                            .padding(.horizontal)

                        if includeDateOfBirth {
                            DatePicker(
                                "Date of Birth",
                                selection: $dateOfBirth,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                            
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
        .navigationDestination(isPresented: $showQRCode) {
            StudentQRCodeView(
                studentID: createdStudentID,
                studentName: name,
                studentClass: studentClass
            )
        }
        .alert("Student Added", isPresented: $showSuccessAlert) {
            Button("OK") {
                showQRCode = true
            }
        } message: {
            Text("The student was added successfully.")
        }
    }
    
    func addStudent() {
        guard !name.isEmpty, !studentClass.isEmpty else {
            message = "Please fill in all fields"
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let ref = db.collection("students").document()
        let studentID = ref.documentID

        let data: [String: Any] = [
            "id": studentID,
            "name": name,
            "studentClass": studentClass,
            "dateOfBirth": includeDateOfBirth ? formatter.string(from: dateOfBirth) : "",
            "sitUps": "",
            "pushUps": "",
            "pullUps": "",
            "shuttleRun": "",
            "standingBroadJump": "",
            "sitAndReach": "",
            "run24km": ""
        ]

        ref.setData(data) { error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
            } else {
                message = "Student added successfully ✅"
                createdStudentID = studentID
                showSuccessAlert = true
            }
        }
    }
}
