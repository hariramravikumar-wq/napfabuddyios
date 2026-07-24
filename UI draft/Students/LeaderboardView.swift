import SwiftUI
import FirebaseFirestore

struct LeaderboardView: View {
    
    @State private var students: [Student] = []
    
    private let db = Firestore.firestore()
    
    var rankedStudents: [Student] {
        students.sorted { first, second in
            let firstScore = totalScore(first)
            let secondScore = totalScore(second)
            return firstScore > secondScore
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("🏆 NAPFA Leaderboard")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                if rankedStudents.isEmpty {
                    Spacer()
                    Text("No students yet")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(Array(rankedStudents.enumerated()), id: \.element.id) { index, student in
                            HStack(spacing: 15) {
                                Text("#\(index + 1)")
                                    .font(.headline)
                                    .frame(width: 45)
                                
                                VStack(alignment: .leading) {
                                    Text(student.name)
                                        .font(.headline)
                                    Text(student.studentClass)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(totalScore(student))")
                                    .bold()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .onAppear {
                loadStudents()
            }
        }
    }
    
    func totalScore(_ student: Student) -> Int {
        let scores = [
            student.sitUps,
            student.pushUps,
            student.pullUps,
            student.shuttleRun,
            student.standingBroadJump,
            student.sitAndReach,
            student.run24km
        ]
        
        return scores.compactMap { Int($0 ?? "") }.reduce(0, +)
    }
    
    func loadStudents() {
        db.collection("students").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            students = documents.map { document in
                let data = document.data()
                
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

#Preview {
    LeaderboardView()
}
