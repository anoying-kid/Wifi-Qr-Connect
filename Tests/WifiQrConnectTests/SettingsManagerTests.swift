import Testing
import Foundation
@testable import WifiQrConnect

@MainActor
struct SettingsManagerTests {
    @Test func testSettingsManagerDefaults() {
        let manager = SettingsManager.shared
        manager.resetDefaults()
        
        #expect(manager.autoConnect == false)
        #expect(manager.playBeep == true)
        #expect(manager.theme == "System")
        
        manager.autoConnect = true
        manager.playBeep = false
        manager.theme = "Dark"
        
        #expect(manager.autoConnect == true)
        #expect(manager.playBeep == false)
        #expect(manager.theme == "Dark")
        
        manager.resetDefaults()
    }
}
