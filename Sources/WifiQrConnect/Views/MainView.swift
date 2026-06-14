import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int? = 0
    @State private var scannedWifi: WiFiDetails? = nil

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                Label("QR Scanner", systemImage: "qrcode.viewfinder")
                    .tag(0 as Int?)
                
                Label("Wi-Fi Info", systemImage: "wifi")
                    .tag(1 as Int?)
            }
            .listStyle(.sidebar)
            .navigationTitle("WiFi QR Connect")
            .frame(minWidth: 180)
        } detail: {
            if selectedTab == 0 {
                ScannerView(scannedWifi: $scannedWifi, selectedTab: $selectedTab)
            } else {
                WifiView(wifiDetails: scannedWifi)
            }
        }
        .frame(minWidth: 720, minHeight: 480)
    }
}
