//
//  Scanner.swift
//  UI draft
//
//  Created by TOH JUN CHEN on 17/6/26.
//
import SwiftUI

struct StationRecord: Identifiable {
    let id = UUID()
    let name: String
    let station: String
    let score: String
}

struct Scanner: View {
    
    @State private var students: [Student] = []
    @State private var records: [StationRecord] = []
    
   
    @State private var activeParticipantName = ""
    @State private var manualName: String = ""

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

    // MARK: - Best-score upsert helpers
    private func isHigherBetter(for station: String) -> Bool {
        // For time-based stations lower is better; others higher is better
        switch station {
        case "Shuttle Run", "1.6km Run":
            return false
        default:
            return true
        }
    }

    private func parseNumeric(from score: String) -> Double? {
        // score strings are formatted like "25 reps", "210 cm", or "12.3 sec"
        // Extract the leading numeric value
        let parts = score.split(separator: " ")
        guard let first = parts.first else { return nil }
        return Double(first.replacingOccurrences(of: ",", with: ""))
    }

    private func upsertBestRecord(_ newRecord: StationRecord) {
        if let idx = records.firstIndex(where: { $0.name == newRecord.name && $0.station == newRecord.station }) {
            let old = records[idx]
            guard let oldVal = parseNumeric(from: old.score), let newVal = parseNumeric(from: newRecord.score) else {
                // If parsing fails, prefer keeping the existing to avoid accidental overwrite
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

                        // Removed manual entry UI from Scan QR Code card
                        
                        Button {
                            // Simulate a scanned payload in the format: Name|Station|ScoreValue
                            let payload = "Scanned Participant|Push-ups|25"
                            let parts = payload.split(separator: "|").map(String.init)
                            if parts.count == 3 {
                                let name = parts[0]
                                let station = parts[1]
                                let value = parts[2]
                                let label = scoreUnitLabel(for: station).replacingOccurrences(of: "Score ", with: "")
                                let unit = label.contains("reps") ? "reps" : label.contains("cm") ? "cm" : "sec"
                                let record = StationRecord(name: name, station: station, score: "\(value) \(unit)")
                                records.append(record)
                            }
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
                    
                    // Manual Entry Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Manual Entry")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Participant Name")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.18, green: 0.24, blue: 0.35))

                            TextField("Enter participant name", text: $manualName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
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

                        // Removed "Record All Stations" button

                        Button {
                            let trimmedName = manualName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmedName.isEmpty, let station = quickAddSelectedStation, !quickAddScore.isEmpty else { return }

                            let label = scoreUnitLabel(for: station).replacingOccurrences(of: "Score ", with: "")
                            let unit = label.contains("reps") ? "reps" : label.contains("cm") ? "cm" : "sec"

                            let record = StationRecord(name: trimmedName, station: station, score: "\(quickAddScore) \(unit)")
                            records.append(record)

                            // Clear inputs
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
                    
                    // Search by Name Card
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
                            // Simulate scan-only name payload: Name|... (we only take the first part as name)
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
                            ForEach(filteredRecords) { log in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(log.name)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.black)
                                            Text("Tap to enter/update all stations")
                                                .font(.system(size: 12))
                                                .foregroundColor(.blue)
                                        }
                                        Spacer()
                                        Text(log.station)
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                        Text(log.score)
                                            .font(.system(size: 18, weight: .black))
                                            .foregroundColor(Color(.systemTeal))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if expandedName == log.name {
                                            expandedName = nil
                                            allStationScores = [:]
                                        } else {
                                            expandedName = log.name
                                            allStationScores = [:]
                                        }
                                    }

                                    if expandedName == log.name {
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
                                                // Upsert per-station scores for this participant, keep editor open
                                                let participant = log.name
                                                for s in stations {
                                                    guard let raw = allStationScores[s]?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { continue }
                                                    let label = scoreUnitLabel(for: s).replacingOccurrences(of: "Score ", with: "")
                                                    let unit = label.contains("reps") ? "reps" : label.contains("cm") ? "cm" : "sec"
                                                    let formatted = "\(raw) \(unit)"
                                                    if let idx = records.firstIndex(where: { $0.name == participant && $0.station == s }) {
                                                        // replace existing
                                                        records[idx] = StationRecord(name: participant, station: s, score: formatted)
                                                    } else {
                                                        // insert new
                                                        records.append(StationRecord(name: participant, station: s, score: formatted))
                                                    }
                                                }
                                                // do NOT collapse; keep expanded and keep the entered values
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
                                        .transition(.opacity)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
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
    }
    

    private func scoreUnitLabel(for station: String) -> String {
        switch station {
        case "Shuttle Run", "1.6km Run": return "Score (sec)"
        case "Standing Broad Jump": return "Score (cm)"
        default: return "Score (reps)"
        }
    }
}

#Preview {
    ContentView()
}

