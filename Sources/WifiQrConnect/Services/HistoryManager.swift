import Foundation

public struct SavedNetwork: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public let ssid: String
    public let password: String
    public let security: String
    public let hidden: Bool
    public let dateScanned: Date

    public init(id: UUID = UUID(), ssid: String, password: String, security: String, hidden: Bool, dateScanned: Date = Date()) {
        self.id = id
        self.ssid = ssid
        self.password = password
        self.security = security
        self.hidden = hidden
        self.dateScanned = dateScanned
    }

    public var wifiDetails: WiFiDetails {
        return WiFiDetails(ssid: ssid, password: password, security: security, hidden: hidden)
    }
}

@MainActor
public class HistoryManager: ObservableObject {
    @Published public var networks: [SavedNetwork] = []
    private let key = "saved_networks_history"

    public static let shared = HistoryManager()

    private init() {
        load()
    }

    public func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([SavedNetwork].self, from: data)
        {
            networks = decoded.sorted(by: { $0.dateScanned > $1.dateScanned })
        }
    }

    public func save() {
        if let encoded = try? JSONEncoder().encode(networks) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    public func add(ssid: String, password: String, security: String, hidden: Bool) {
        // Remove duplicate entry if it exists to refresh its position at the top
        if let existingIndex = networks.firstIndex(where: { $0.ssid == ssid }) {
            networks.remove(at: existingIndex)
        }

        let newNetwork = SavedNetwork(
            id: UUID(),
            ssid: ssid,
            password: password,
            security: security,
            hidden: hidden,
            dateScanned: Date()
        )

        networks.insert(newNetwork, at: 0)
        save()
    }

    public func remove(at offsets: IndexSet) {
        networks.remove(atOffsets: offsets)
        save()
    }

    public func remove(_ network: SavedNetwork) {
        if let index = networks.firstIndex(of: network) {
            networks.remove(at: index)
            save()
        }
    }

    public func clearAll() {
        networks.removeAll()
        save()
    }
}
