import SwiftUI

struct StudentDashboardView: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.8), .cyan.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("Welcome, Student!")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Ready to improve your NAPFA score?")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    VStack(spacing: 18) {
                        
                        NavigationLink {
                            QRScannerView { result in
                                // Handle scanned result here
                                // You can replace this with navigation or state updates as needed
                                print("Scanned result: \(result)")
                            }
                        } label: {
                            DashboardButton(
                                title: "Scan QR Code",
                                icon: "qrcode"
                            )
                        }
                        
                        NavigationLink {
                            LeaderboardView()
                        } label: {
                            DashboardButton(
                                title: "Leaderboard",
                                icon: "trophy.fill"
                            )
                        }
                        
                        NavigationLink {
                            Text("Profile coming soon")
                        } label: {
                            DashboardButton(
                                title: "My Profile",
                                icon: "person.fill"
                            )
                        }
                        
                        NavigationLink {
                            Text("Achievements coming soon")
                        } label: {
                            DashboardButton(
                                title: "Achievements",
                                icon: "medal.fill"
                            )
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Student Dashboard")
        }
    }
}


struct DashboardButton: View {
    
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
            
            Text(title)
                .font(.headline)
            
            Spacer()
        }
        .frame(width: 280)
        .padding()
        .background(.white)
        .foregroundColor(.blue)
        .cornerRadius(15)
    }
}


#Preview {
    StudentDashboardView()
}
