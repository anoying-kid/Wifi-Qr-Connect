import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int? = 0

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
                    Label("History", systemImage: "clock")
                }

                NavigationLink(value: 3) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("WiFi QR Connect")
            .frame(minWidth: 180)
        } detail: {
            if selectedTab == 0 {
                ScannerView()
            } else if selectedTab == 1 {
                WifiView()
            } else if selectedTab == 2 {
                HistoryView()
            } else {
                SettingsView()
            }
        }
        .frame(minWidth: 720, minHeight: 480)
    }
}
