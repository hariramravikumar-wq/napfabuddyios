//
//  ManualInput.swift
//  UI draft
//
//  Created by TOH JUN CHEN on 17/6/26.
//
import SwiftUI

struct ManualInput: View {
    
   
    @State private var activeParticipantName = ""
    @State private var participantInput = ""
    
    
    @State private var showModal = false
    @State private var selectedStation: String? = nil
    @State private var score = ""
    
    let stations = [
        "Sit-ups",
        "Push-ups",
        "Pull-ups",
        "Shuttle Run",
        "Standing Broad Jump",
        "1.6km Run"
    ]

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.96, blue: 0.99)
                .ignoresSafeArea()
            VStack(spacing: 20) {
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
                .padding(.top, 10)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add Participant")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 12) {
                        TextField("Search student...", text: $participantInput)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        Button {
                            if !participantInput.isEmpty {
                                activeParticipantName = participantInput
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showModal = true
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "person.badge.plus.fill")
                                Text("Add")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                
                // Bottom Status Empty State Card
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 45))
                        .foregroundColor(.gray)
                        .opacity(0.5)
                    
                    Text("No records yet")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text("Add a participant to get started")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                
            }
            .padding(.horizontal, 20)
            
            // 3. Dimming Layer Background
            if showModal {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation { dismissModal() }
                    }
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Record Station Score")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 4) {
                            Text("Participant:")
                                .foregroundColor(.gray)
                            Text(activeParticipantName)
                                .bold()
                                .foregroundColor(.black)
                        }
                    }
                    
                    // Dropdown Station Menu Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Station")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0.18, green: 0.24, blue: 0.35))
                        
                        Menu {
                            ForEach(stations, id: \.self) { station in
                                Button(station) {
                                    selectedStation = station
                                    score = ""
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedStation ?? "Choose a station...")
                                    .foregroundColor(selectedStation == nil ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
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
                    
                    
                    if let station = selectedStation {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(scoreUnitLabel(for: station))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.18, green: 0.24, blue: 0.35))
                            
                            TextField("Enter \(station.lowercased()) score", text: $score)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1.5)
                                )
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    
                    HStack(spacing: 12) {
                        Button {
                            if selectedStation != nil {
                                withAnimation { dismissModal() }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Submit")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.58, green: 0.83, blue: 0.65))
                            .cornerRadius(10)
                        }
                        .disabled(selectedStation == nil || score.isEmpty)
                        .opacity(selectedStation == nil || score.isEmpty ? 0.6 : 1.0)
                        
                        Button {
                            withAnimation { dismissModal() }
                        } label: {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Done")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 0.18, green: 0.24, blue: 0.35))
                            .frame(width: 100)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
    }
    
    
    private func dismissModal() {
        showModal = false
        selectedStation = nil
        score = ""
        participantInput = ""
    }
    
    private func scoreUnitLabel(for station: String) -> String {
        switch station {
        case "Shuttle Run", "2.4km Run": return "Score (sec)"
        case "Standing Broad Jump": return "Score (cm)"
        default: return "Score (reps)"
        }
    }
}

#Preview {
    ContentView()
}
