import SwiftUI
import FirebaseFirestore

struct StationEntryView: View {
    
    let station: String
    
    @State private var students: [Student] = []
    @State private var selectedStudentID: String?
    @State private var score = ""
    @State private var message = ""
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(spacing: 25) {
            
            Image(systemName: "figure.run")
                .font(.system(size: 70))
                .foregroundColor(.blue)
            
            Text(station)
                .font(.largeTitle)
                .bold()
            
            Text("Enter student performance")
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                
                Picker("Select Student", selection: $selectedStudentID) {
                    Text("Select Student").tag(nil as String?)
                    
                    ForEach(students) { student in
                        Text(student.name).tag(Optional(student.id))
                    }
                }
                .pickerStyle(.menu)
                
                TextField("Score", text: $score)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    submitScore()
                } label: {
                    Text("Submit Score")
                        .frame(width: 220)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            }
            .padding()
            
            Text(message)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Station Entry")
        .onAppear {
            loadStudents()
        }
    }
    
    func loadStudents() {
        db.collection("students").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                students = documents.map { document in
                    let data = document.data()
                    return Student(
                        id: document.documentID,
                        name: data["name"] as? String ?? "Unknown",
                        studentClass: data["studentClass"] as? String ?? "-"
                    )
                }
            }
        }
    }
    
    func submitScore() {
        guard let selectedID = selectedStudentID,
              let student = students.first(where: { $0.id == selectedID }),
              !score.isEmpty else {
            message = "Please select a student and enter a score"
            return
        }
        
        let field: String
        
        switch station {
        case "Push Ups":
            field = "pushUps"
        case "Shuttle Run":
            field = "shuttleRun"
        case "Standing Broad Jump":
            field = "standingBroadJump"
        default:
            field = station
        }
        
        db.collection("students")
            .document(student.id)
            .updateData([
                field: score
            ]) { error in
                if let error = error {
                    message = "Error: \(error.localizedDescription)"
                } else {
                    message = "Score saved ✅"
                    score = ""
                }
            }
    }
}
