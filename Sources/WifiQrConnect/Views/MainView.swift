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
            switch selectedTab {
            case 0:
                ScannerView()
            case 1:
                WifiView()
            case 2:
                HistoryView()
            case 3:
                SettingsView()
            default:
                ScannerView()
            }
        }
        .frame(minWidth: 720, minHeight: 480)
    }
}
