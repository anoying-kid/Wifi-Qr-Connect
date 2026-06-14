import Foundation

@MainActor
public class SettingsManager: ObservableObject {
    @Published public var autoConnect: Bool {
        didSet {
            UserDefaults.standard.set(autoConnect, forKey: "settings_auto_connect")
        }
    }
    
    @Published public var playBeep: Bool {
        didSet {
            UserDefaults.standard.set(playBeep, forKey: "settings_play_beep")
        }
    }
    
    @Published public var theme: String {
        didSet {
            UserDefaults.standard.set(theme, forKey: "settings_theme")
        }
    }
    
    public static let shared = SettingsManager()
    
    private init() {
        self.autoConnect = UserDefaults.standard.bool(forKey: "settings_auto_connect")
        
        if UserDefaults.standard.object(forKey: "settings_play_beep") == nil {
            self.playBeep = true
        } else {
            self.playBeep = UserDefaults.standard.bool(forKey: "settings_play_beep")
        }
        
        self.theme = UserDefaults.standard.string(forKey: "settings_theme") ?? "System"
    }
    
    public func resetDefaults() {
        self.autoConnect = false
        self.playBeep = true
        self.theme = "System"
    }
}
