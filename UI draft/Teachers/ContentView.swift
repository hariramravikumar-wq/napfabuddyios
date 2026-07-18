import SwiftUI

@MainActor
struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var auth: AuthenticationManager

    init(auth: AuthenticationManager) {
        _auth = ObservedObject(wrappedValue: auth)
    }
    
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
                                ManageStudentsView(auth: AuthenticationManager())
                            } label: {
                                Text("👨‍🎓 Manage Students")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 320)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(15)
                            }
                            .padding(.horizontal)

                            if auth.isAdmin {
                                NavigationLink {
                                    ManageTeachersView(auth: AuthenticationManager())
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
                            Text("Logged in as: \(auth.teacherName.isEmpty ? "Unknown Teacher" : auth.teacherName)")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("Role: \(auth.teacherRole.isEmpty ? "Unknown" : auth.teacherRole.capitalized)")
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
                            dismiss()
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
    ContentView(auth: AuthenticationManager())
}
