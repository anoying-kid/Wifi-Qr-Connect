import CoreLocation
import Foundation

@MainActor
public class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = LocationManager()

    private let manager = CLLocationManager()

    @Published public var authorizationStatus: CLAuthorizationStatus

    override private init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }

    public func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
        }
    }
}
