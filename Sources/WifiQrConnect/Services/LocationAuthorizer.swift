import CoreLocation
import Foundation

@MainActor
public class LocationAuthorizer: NSObject, CLLocationManagerDelegate, ObservableObject {
    public static let shared = LocationAuthorizer()
    private let manager = CLLocationManager()

    @Published public var isAuthorized: Bool = false

    override private init() {
        super.init()
        manager.delegate = self
        checkStatus()
    }

    public func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    public func checkStatus() {
        let status = manager.authorizationStatus
        isAuthorized = (status != .notDetermined && status != .denied && status != .restricted)
    }

    public nonisolated func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        Task { @MainActor in
            self.checkStatus()
            NotificationCenter.default.post(name: Notification.Name("LocationAuthorizationChanged"), object: nil)
        }
    }
}
