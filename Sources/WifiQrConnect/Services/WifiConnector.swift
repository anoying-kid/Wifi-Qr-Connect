import CoreWLAN
import Foundation

public enum WifiConnectorError: LocalizedError {
    case noInterface
    case networkNotFound(ssid: String)
    case associationFailed(reason: String)

    public var errorDescription: String? {
        switch self {
        case .noInterface:
            return "No Wi-Fi interface found."
        case let .networkNotFound(ssid):
            return "Wi-Fi network '\(ssid)' not found in scan results. Please make sure it is in range."
        case let .associationFailed(reason):
            return "Failed to connect to the network: \(reason)"
        }
    }
}

public class WifiConnector {
    public static func connect(details: WiFiDetails) async throws {
        // Run CoreWLAN operations in a detached task to avoid blocking the main thread.
        let task = Task.detached(priority: .userInitiated) {
            guard let interface = CWWiFiClient.shared().interface() else {
                throw WifiConnectorError.noInterface
            }

            let ssidData = details.ssid.data(using: .utf8)

            // Scan for networks matching the SSID, including hidden networks if specified.
            let networks: Set<CWNetwork>
            do {
                networks = try interface.scanForNetworks(withSSID: ssidData, includeHidden: details.hidden)
            } catch {
                networks = try interface.scanForNetworks(withSSID: ssidData)
            }

            guard let targetNetwork = networks.first else {
                throw WifiConnectorError.networkNotFound(ssid: details.ssid)
            }

            let password = (details.security.lowercased() == "nopass" || details.password.isEmpty) ? nil : details.password

            do {
                try interface.associate(to: targetNetwork, password: password)
            } catch {
                throw WifiConnectorError.associationFailed(reason: error.localizedDescription)
            }
        }
        try await task.value
    }
}
