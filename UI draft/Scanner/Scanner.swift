//
//  Scanner.swift
//  UI draft
//
//  Created by TOH JUN CHEN on 17/6/26.
//
import SwiftUI
import FirebaseFirestore

struct StationRecord: Identifiable {
    let id = UUID()
    let name: String
    let studentID: String?
    let station: String
    let score: String
}

struct Scanner: View {
    private func loadStudents() {
        let db = Firestore.firestore()

        db.collection("students")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to load students:", error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found in students collection")
                    return
                }

                let loadedStudents = documents.compactMap { document -> Student? in
                    let data = document.data()

                    guard let name = data["name"] as? String,
                          !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        return nil
                    }

                    return Student(
                        id: document.documentID,
                        name: name,
                        studentClass: data["studentClass"] as? String ?? "Unknown"
                    )
                }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

                print("Loaded students:", loadedStudents.map { $0.name })

                DispatchQueue.main.async {
                    students = loadedStudents
                }
            }
    }
    
    @State private var students: [Student] = []
    @State private var records: [StationRecord] = []

    @State private var activeParticipantName = ""
    @State private var manualName: String = ""

    // QR Scanner
    @State private var showQRScanner = false
    @State private var scannedID = ""

    // Student sheet
    @State private var selectedStudent: Student?
    @State private var showStationEntry = false

    @State private var quickAddSelectedStation: String? = nil
    @State private var quickAddScore: String = ""
    @State private var allStationScores: [String: String] = [:]
    @State private var showAllStationsSheet: Bool = false
    
    @State private var searchName: String = ""
    @State private var expandedName: String? = nil
    
    private var stationBindings: [(station: String, binding: Binding<String>)] {
        stations.map { s in
            return (s, Binding(
                get: { allStationScores[s] ?? "" },
                set: { newValue in allStationScores[s] = newValue }
            ))
        }
    }

    private var filteredRecords: [StationRecord] {
        let trimmed = searchName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return records }
        return records.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }
    
    private var trimmedManualNameIsEmpty: Bool {
        manualName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    let stations = [
        "Sit-ups",
        "Push-ups",
        "Pull-ups",
        "Shuttle Run",
        "Standing Broad Jump",
        "1.6km Run"
    ]

   
    private func isHigherBetter(for station: String) -> Bool {
      
        switch station {
        case "Shuttle Run", "1.6km Run":
            return false
        default:
            return true
        }
    }

    private func parseNumeric(from score: String) -> Double? {
       
        let parts = score.split(separator: " ")
        guard let first = parts.first else { return nil }
        return Double(first.replacingOccurrences(of: ",", with: ""))
    }

    private func upsertBestRecord(_ newRecord: StationRecord) {
        if let idx = records.firstIndex(where: { $0.name == newRecord.name && $0.station == newRecord.station }) {
            let old = records[idx]
            guard let oldVal = parseNumeric(from: old.score), let newVal = parseNumeric(from: newRecord.score) else {
               
                return
            }
            if isHigherBetter(for: newRecord.station) {
                if newVal > oldVal { records[idx] = newRecord }
            } else {
                if newVal < oldVal { records[idx] = newRecord }
            }
        } else {
            records.append(newRecord)
        }
    }
    private func handleQRScan(_ result: String) {

        showQRScanner = false
        scannedID = result

        print("QR Result:", result)

        findStudent(id: result)
    }


    private func findStudent(id: String) {
        let db = Firestore.firestore()

        db.collection("students")
            .document(id)
            .getDocument { snapshot, error in
                if let error = error {
                    print("Firestore error:", error.localizedDescription)
                    return
                }

                guard let data = snapshot?.data() else {
                    print("Student not found in students collection")
                    return
                }

                let student = Student(
                    id: id,
                    name: data["name"] as? String ?? "Unknown",
                    studentClass: data["studentClass"] as? String ?? "Unknown"
                )

                DispatchQueue.main.async {
                    selectedStudent = student
                    showStationEntry = true
                }
            }
    }
    var body: some View {
        ZStack {
           
            Color(red: 0.95, green: 0.96, blue: 0.99)
                .ignoresSafeArea()
            
          
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    
                    VStack(spacing: 8) {
                        Image(systemName: "clipboard.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Fitness Test Scoring")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.05, green: 0.1, blue: 0.22))
                        
                        Text("Record scores for all test stations")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Scan QR Code")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                       
                        VStack(spacing: 14) {
                            Image(systemName: "camera.slash.fill")
                                .font(.system(size: 42))
                                .foregroundColor(.gray)
                                .opacity(0.6)
                            
                            Text("Camera is off")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
                        .cornerRadius(12)

                        
                        Button {

                            showQRScanner = true

                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                Text("Start Scanning")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Manual Entry")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Participant Name")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.18, green: 0.24, blue: 0.35))

                            Picker("Select participant", selection: $manualName) {
                                Text("Select participant")
                                    .tag("")

                                ForEach(students) { student in
                                    Text("\(student.name)\(student.studentClass == "Unknown" ? "" : " — \(student.studentClass)")")
                                        .tag(student.name)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Station")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.18, green: 0.24, blue: 0.35))

                            Menu {
                                ForEach(stations, id: \.self) { station in
                                    Button(station) { quickAddSelectedStation = station }
                                }
                            } label: {
                                HStack {
                                    Text(quickAddSelectedStation ?? "Select station…")
                                        .foregroundColor(quickAddSelectedStation == nil ? .gray : .black)
                                    Spacer()
                                    Image(systemName: "chevron.down").foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Score")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.18, green: 0.24, blue: 0.35))

                            TextField("Enter score", text: $quickAddScore)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }

                        

                        Button {
                            let trimmedName = manualName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmedName.isEmpty, let station = quickAddSelectedStation, !quickAddScore.isEmpty else { return }

                            let label = scoreUnitLabel(for: station).replacingOccurrences(of: "Score ", with: "")
                            let unit = label.contains("reps") ? "reps" : label.contains("cm") ? "cm" : "sec"

                            let record = StationRecord(
                                name: trimmedName,
                                studentID: students.first(where: { $0.name == trimmedName })?.id,
                                station: station,
                                score: "\(quickAddScore) \(unit)"
                            )
                            upsertBestRecord(record)

                            manualName = ""
                            quickAddSelectedStation = nil
                            quickAddScore = ""
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Record")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background((manualName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || quickAddSelectedStation == nil || quickAddScore.isEmpty) ? Color.gray : Color.green)
                            .cornerRadius(10)
                        }
                        .disabled(manualName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || quickAddSelectedStation == nil || quickAddScore.isEmpty)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    
                   
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Search by Name")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)

                        TextField("Type a name to filter records", text: $searchName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )

                        Button {
                            
                            let payload = "Scanned Participant|ignored|ignored"
                            let name = payload.split(separator: "|").first.map(String.init) ?? ""
                            searchName = name
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Scan to Search")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.purple)
                            .cornerRadius(10)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                  
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Activity Log Records")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        if filteredRecords.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                    .opacity(0.4)
                                Text(searchName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No records yet" : "No matches for \"\(searchName)\"")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.gray)
                                Text(searchName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Scan a QR code to log results" : "Try a different name or clear the search")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            let grouped = Dictionary(grouping: filteredRecords, by: { $0.name })
                            VStack(spacing: 12) {
                                ForEach(grouped.keys.sorted(), id: \.self) { name in
                                    let logsForName = grouped[name] ?? []
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(name)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.black)
                                            Spacer()
                                            Image(systemName: expandedName == name ? "chevron.up" : "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            if expandedName == name {
                                                expandedName = nil
                                                allStationScores = [:]
                                            } else {
                                                expandedName = name
                                                allStationScores = [:]
                                            }
                                        }

                                        if expandedName == name {
                                            VStack(alignment: .leading, spacing: 8) {
                                                ForEach(stations, id: \.self) { s in
                                                    HStack {
                                                        Text(s)
                                                            .font(.system(size: 14))
                                                            .foregroundColor(.blue)
                                                        Spacer()
                                                        if let existing = logsForName.first(where: { $0.station == s }) {
                                                            Text(existing.score)
                                                                .font(.system(size: 16, weight: .semibold))
                                                                .foregroundColor(Color(.systemTeal))
                                                        } else {
                                                            Text("-")
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                }

                                                VStack(alignment: .leading, spacing: 12) {
                                                    ForEach(stations, id: \.self) { s in
                                                        VStack(alignment: .leading, spacing: 6) {
                                                            Text(s)
                                                                .font(.system(size: 14, weight: .semibold))
                                                                .foregroundColor(Color(red: 0.18, green: 0.24, blue: 0.35))
                                                            TextField(scoreUnitLabel(for: s), text: Binding(
                                                                get: { allStationScores[s] ?? "" },
                                                                set: { allStationScores[s] = $0 }
                                                            ))
                                                            .keyboardType(.decimalPad)
                                                            .padding(10)
                                                            .background(Color.white)
                                                            .cornerRadius(8)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .stroke(Color(.systemGray4), lineWidth: 1)
                                                            )
                                                        }
                                                    }

                                                    Button {
                                                        let participant = name
                                                        for s in stations {
                                                            guard let raw = allStationScores[s]?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { continue }
                                                            let label = scoreUnitLabel(for: s).replacingOccurrences(of: "Score ", with: "")
                                                            let unit = label.contains("reps") ? "reps" : label.contains("cm") ? "cm" : "sec"
                                                            let formatted = "\(raw) \(unit)"
                                                            upsertBestRecord(
                                                                StationRecord(
                                                                    name: participant,
                                                                    studentID: students.first(where: { $0.name == participant })?.id,
                                                                    station: s,
                                                                    score: formatted
                                                                )
                                                            )
                                                        }
                                                    } label: {
                                                        HStack(spacing: 8) {
                                                            Image(systemName: "checkmark")
                                                            Text("Save")
                                                        }
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 10)
                                                        .background(Color.green)
                                                        .cornerRadius(8)
                                                    }
                                                }
                                            }
                                            .transition(.opacity)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            
        }
        .sheet(isPresented: $showQRScanner) {
            if #available(iOS 16.0, *) {
                QRScannerView { result in
                    handleQRScan(result)
                }
            } else {
                Text("QR Scanner requires iOS 16+")
            }
        }
        .sheet(isPresented: $showStationEntry) {
            if let student = selectedStudent {
                StationEntryView(
                    student: student,
                    stations: stations,
                    onSave: { station, score in
                        let unit: String
                        switch station {
                        case "Shuttle Run", "1.6km Run":
                            unit = "sec"
                        case "Standing Broad Jump":
                            unit = "cm"
                        default:
                            unit = "reps"
                        }

                        let formattedScore = "\(score) \(unit)"

                        upsertBestRecord(
                            StationRecord(
                                name: student.name,
                                studentID: student.id,
                                station: station,
                                score: formattedScore
                            )
                        )

                        Firestore.firestore()
                            .collection("students")
                            .document(student.id)
                            .collection("scores")
                            .document(station)
                            .setData([
                                "station": station,
                                "score": score,
                                "unit": unit,
                                "studentID": student.id,
                                "studentName": student.name,
                                "recordedAt": FieldValue.serverTimestamp()
                            ]) { error in
                                if let error = error {
                                    print("Failed to save score:", error.localizedDescription)
                                } else {
                                    print("Score saved successfully")
                                }
                            }
                    }
                )
            }
        }
        .onAppear {
            loadStudents()
        }
        .refreshable {
            loadStudents()
        }
    }
    

    private func scoreUnitLabel(for station: String) -> String {
        switch station {
        case "Shuttle Run", "1.6km Run": return "Score (sec)"
        case "Standing Broad Jump": return "Score (cm)"
        default: return "Score (reps)"
        }
    }
}

# Add StationEntryView before #Preview
struct StationEntryView: View {
    let student: Student
    let stations: [String]
    let onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedStation = ""
    @State private var score = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Student") {
                    Text(student.name)
                        .font(.headline)

                    if student.studentClass != "Unknown" {
                        Text("Class: \(student.studentClass)")
                            .foregroundColor(.secondary)
                    }
                }

                Section("NAPFA Station") {
                    Picker("Station", selection: $selectedStation) {
                        Text("Select a station")
                            .tag("")

                        ForEach(stations, id: \.self) { station in
                            Text(station)
                                .tag(station)
                        }
                    }

                    TextField("Enter score", text: $score)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Button {
                        guard !selectedStation.isEmpty,
                              !score.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                            return
                        }

                        onSave(selectedStation, score)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save Score")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(
                        selectedStation.isEmpty ||
                        score.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
            .navigationTitle("Record Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("Scanner Preview") {
    let previewAuth = AuthenticationManager()
    ContentView(auth: previewAuth)
}
