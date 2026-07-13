import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthenticationManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Screenshot 2026-05-25 at 4.30.28 PM")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        Spacer().frame(height: 30)

                        Image(systemName: "clipboard.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.yellow)

                        Text("NAPFA Buddy")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.black)

                        Text("Teacher Dashboard")
                            .font(.title2)
                            .foregroundColor(.black.opacity(0.8))

                        VStack(spacing: 14) {
                            NavigationLink {
                                Scanner()
                            } label: {
                                Text("📷 Record NAPFA Scores")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 320)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(15)
                            }
                            .padding(.horizontal)

                            NavigationLink {
                                StationScannerView()
                            } label: {
                                Text("📍 Scan NAPFA Station")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 320)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(15)
                            }
                            .padding(.horizontal)

                            VStack(spacing: 10) {
                                Text("Developer Testing")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                NavigationLink {
                                    StationEntryView(station: "Push Ups")
                                } label: {
                                    Text("🧪 Test Push Up Station")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 280)
                                        .padding()
                                        .background(Color.purple)
                                        .cornerRadius(12)
                                }

                                NavigationLink {
                                    StationEntryView(station: "Shuttle Run")
                                } label: {
                                    Text("🧪 Test Shuttle Run Station")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 280)
                                        .padding()
                                        .background(Color.purple)
                                        .cornerRadius(12)
                                }

                                NavigationLink {
                                    StationEntryView(station: "Standing Broad Jump")
                                } label: {
                                    Text("🧪 Test Standing Broad Jump")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 280)
                                        .padding()
                                        .background(Color.purple)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.top, 10)

                            if auth.isAdmin {
                                NavigationLink {
                                    ManageTeachersView()
                                } label: {
                                    Text("👨‍🏫 Manage Teachers")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: 320)
                                        .padding()
                                        .background(Color.orange)
                                        .cornerRadius(15)
                                }
                                .padding(.horizontal)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Logged in as: \(auth.teacherName)")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("Role: \(auth.teacherRole.capitalized)")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: 320, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.92))
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 10)

                        Spacer()

                        Button(action: {
                            auth.signOut()
                        }) {
                            Text("Sign Out")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(maxWidth: 320)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
