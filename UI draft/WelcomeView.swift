//
//  WelcomeView.swift
//  UI draft
//

import SwiftUI

struct WelcomeView: View {

    @StateObject private var auth = AuthenticationManager()

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Screenshot 2026-05-25 at 4.30.28 PM")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.25))

                VStack(spacing: 25) {
                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 70))
                            .foregroundColor(.yellow)

                        Text("NAPFA Buddy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Your personal fitness companion")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))

                        Text("Track • Improve • Achieve")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    VStack(spacing: 18) {
                        NavigationLink(destination: StudentDashboardView()) {
                            Label("Continue as Student", systemImage: "person.fill")
                                .font(.headline)
                                .frame(width: 280)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }

                        NavigationLink(destination: TeacherLoginView(auth: auth)) {
                            Label("Teacher Login", systemImage: "person.badge.key.fill")
                                .font(.headline)
                                .frame(width: 280)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    .padding(25)
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)

                    Spacer()

                    Text("Train smarter. Reach further.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 30)
            }
        }
    }

}

#Preview {
    WelcomeView()
}
