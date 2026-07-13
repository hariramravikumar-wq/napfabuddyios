import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            ZStack {
                Image("Screenshot 2026-05-25 at 4.30.28 PM")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "clipboard.fill")
                        .font(.system(size: 45))
                        .foregroundColor(.yellow)
                
                    Text("NapfaTest Scoring")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Record scores for all test stations")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .foregroundColor(.black)
                    HStack {
                        Spacer()
                        
                        NavigationLink {
                            Scanner()
                        } label: {
                            Text("Scanner")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        
                        NavigationLink {
                            ManualInput()
                        } label: {
                            Text("Manual  ")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        
                        Spacer()
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.top, 250)
                
            }
        }
    }
}
#Preview {
    ContentView()
}
