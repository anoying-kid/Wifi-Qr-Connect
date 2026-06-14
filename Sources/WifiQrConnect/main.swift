import SwiftUI

struct WifiQrConnectApp: App {
    @ObservedObject var settings = SettingsManager.shared
    
    var colorScheme: ColorScheme? {
        switch settings.theme {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(colorScheme)
        }
    }
}

WifiQrConnectApp.main()
