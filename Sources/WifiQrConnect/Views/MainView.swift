import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int? = 0
    @State private var scannedWifi: WiFiDetails? = nil

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                NavigationLink(value: 0) {
                    Label("QR Scanner", systemImage: "qrcode.viewfinder")
                }
                
                NavigationLink(value: 1) {
                    Label("Wi-Fi Info", systemImage: "wifi")
                }
                
                NavigationLink(value: 2) {
                    Label("Generate QR", systemImage: "qrcode")
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("WiFi QR Connect")
            .frame(minWidth: 180)
        } detail: {
            if selectedTab == 0 {
                ScannerView(scannedWifi: $scannedWifi, selectedTab: $selectedTab)
            } else if selectedTab == 1 {
                WifiView(wifiDetails: scannedWifi)
            } else {
                GenerateQRView()
            }
        }
        .frame(minWidth: 720, minHeight: 480)
    }
}
