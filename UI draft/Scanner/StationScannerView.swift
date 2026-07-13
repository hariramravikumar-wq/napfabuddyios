import SwiftUI

struct StationScannerView: View {
    
    @State private var scannedStation: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if let station = scannedStation {
                    
                    NavigationLink(
                        destination: StationEntryView(station: station),
                        isActive: Binding(
                            get: { scannedStation != nil },
                            set: { active in
                                if !active {
                                    scannedStation = nil
                                }
                            }
                        )
                    ) {
                        EmptyView()
                    }
                    
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
