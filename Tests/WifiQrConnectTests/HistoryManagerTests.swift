import Foundation
import Testing
@testable import WifiQrConnect

@MainActor
struct HistoryManagerTests {
    @Test func historyManagerOperations() throws {
        let manager = HistoryManager.shared
        manager.clearAll()
        #expect(manager.networks.isEmpty)

        manager.add(ssid: "TestNet1", password: "pw1", security: "WPA", hidden: false)
        #expect(manager.networks.count == 1)
        #expect(manager.networks.first?.ssid == "TestNet1")

        // Add duplicate should refresh position and keep count at 1
        manager.add(ssid: "TestNet1", password: "pw2", security: "WPA", hidden: false)
        #expect(manager.networks.count == 1)
        #expect(manager.networks.first?.password == "pw2")

        manager.add(ssid: "TestNet2", password: "pw3", security: "WEP", hidden: true)
        #expect(manager.networks.count == 2)
        #expect(manager.networks.first?.ssid == "TestNet2")

        let firstNetwork = try #require(manager.networks.first)
        manager.remove(firstNetwork)
        #expect(manager.networks.count == 1)
        #expect(manager.networks.first?.ssid == "TestNet1")

        manager.clearAll()
        #expect(manager.networks.isEmpty)
    }
}
