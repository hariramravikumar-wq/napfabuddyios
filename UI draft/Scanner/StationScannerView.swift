import SwiftUI

struct StationScannerView: View {
    
    @State private var scannedStation: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if let station = scannedStation {
                    NavigationLink {
                        StationEntryView(station: station)
                    } label: {
                        EmptyView()
                    }
                    .hidden()
                } else {
                    
                    if #available(iOS 16.0, *) {
                        QRScannerView { result in
                            scannedStation = result
                        }
                        .ignoresSafeArea()
                    } else {
                        Text("QR Scanner requires iOS 16")
                    }
                    
                }
            }
            .navigationTitle("Scan Station")
        }
    }
}
