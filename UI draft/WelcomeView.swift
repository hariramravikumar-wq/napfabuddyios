//
//  WelcomeView.swift
//  UI draft
//

import SwiftUI

struct WelcomeView: View {

    var body: some View {

        NavigationStack {

            ZStack {

                Image("Screenshot 2026-05-25 at 4.30.28 PM")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 35) {

                    Spacer()

                    Image(systemName: "clipboard.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.yellow)

                    Text("NAPFA Buddy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text("Select how you would like to continue")
                        .font(.title3)
                        .foregroundColor(.black)

                    Spacer()

                    NavigationLink(destination: LeaderboardView()) {

                        Label("Continue as Student", systemImage: "person.fill")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)

                    }

                    NavigationLink(destination: TeacherLoginView()) {

                        Label("Teacher Login", systemImage: "person.badge.key.fill")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)

                    }

                    Spacer()

                }
                .padding(.horizontal, 30)

            }

        }

    }

}

#Preview {
    WelcomeView()
}
