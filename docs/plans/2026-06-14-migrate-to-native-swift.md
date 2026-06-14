# Migrate Wifi-Qr-Connect to Native Swift

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Convert the Wifi-Qr-Connect application from Flutter to a native macOS Swift/SwiftUI application utilizing SwiftPM packaging (no Xcode project needed) and CoreWLAN for native Wi-Fi connection.

**Architecture:** A native macOS menu/window application built with SwiftUI. It has a sidebar layout containing a QR scanner and a Wi-Fi info pane. It integrates with `AVFoundation` for native camera scanning and `CoreWLAN` for Wi-Fi configurations.

**Tech Stack:** Swift 6.2, SwiftUI, AVFoundation, CoreWLAN.

---

### Task 1: Bootstrap the SwiftPM App
Set up the Swift Package Manager file structure and copy the bootstrap template.

**Files:**
- Create: `Package.swift`
- Create: `Sources/WifiQrConnect/main.swift`
- Create: `version.env`
- Create: `Scripts/package_app.sh`
- Create: `Scripts/compile_and_run.sh`

**Step 1: Bootstrap files**
Copy templates from the `macos-spm-app-packaging` skill:
```bash
cp /Users/anon/.gemini/antigravity-cli/skills/macos-spm-app-packaging/assets/templates/bootstrap/Package.swift ./
cp /Users/anon/.gemini/antigravity-cli/skills/macos-spm-app-packaging/assets/templates/bootstrap/version.env ./
mkdir -p Sources/WifiQrConnect
cp /Users/anon/.gemini/antigravity-cli/skills/macos-spm-app-packaging/assets/templates/bootstrap/Sources/MyApp/main.swift Sources/WifiQrConnect/main.swift
mkdir -p Scripts
cp /Users/anon/.gemini/antigravity-cli/skills/macos-spm-app-packaging/assets/templates/package_app.sh Scripts/
cp /Users/anon/.gemini/antigravity-cli/skills/macos-spm-app-packaging/assets/templates/compile_and_run.sh Scripts/
chmod +x Scripts/*.sh
```

**Step 2: Rename target name**
Replace `MyApp` with `WifiQrConnect` in `Package.swift`, `version.env`, and `main.swift`.
In `Package.swift`:
```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "WifiQrConnect",
    platforms: [
        .macOS(.v14),
    ],
    targets: [
        .executableTarget(
            name: "WifiQrConnect",
            path: "Sources/WifiQrConnect",
            resources: [])
    ]
)
```

**Step 3: Run the compile and run script**
Run: `Scripts/compile_and_run.sh`
Expected: App compiles and a window with "Hello from MyApp" opens.

**Step 4: Commit**
```bash
git add Package.swift version.env Sources/WifiQrConnect/main.swift Scripts/
git commit -m "feat: bootstrap native Swift app structure"
```

---

### Task 2: Implement QR Code Parser
Write the utility that parses the standard Wi-Fi QR code string format (e.g. `WIFI:T:WPA;S:MyNetwork;P:myPassword;;`).

**Files:**
- Create: `Sources/WifiQrConnect/Services/QRParser.swift`
- Create: `Tests/WifiQrConnectTests/QRParserTests.swift`

**Step 1: Write tests for parsing**
Create the test target under `Tests/` and write assertions for different QR string configurations (WPA, WEP, Open, escaped characters).

**Step 2: Implement the parsing logic**
Write `QRParser.swift`:
```swift
struct WiFiDetails {
    let ssid: String
    let password: String
    let security: String // WPA, WEP, nopass
}

struct QRParser {
    static func parse(qrString: String) -> WiFiDetails? {
        guard qrString.hasPrefix("WIFI:") else { return nil }
        // regex or string token parsing for S:, P:, T:
        // ...
        return WiFiDetails(ssid: ssid, password: password, security: security)
    }
}
```

**Step 3: Run tests to verify**
Run: `swift test`
Expected: PASS

**Step 4: Commit**
```bash
git commit -m "feat: add WiFi QR string parser and unit tests"
```

---

### Task 3: Implement Wi-Fi Connector
Integrate the CoreWLAN framework to associate to scanned networks natively.

**Files:**
- Create: `Sources/WifiQrConnect/Services/WifiConnector.swift`

**Step 1: Write the connector logic**
Implement `WifiConnector` wrapping CoreWLAN APIs:
```swift
import CoreWLAN

class WifiConnector {
    static func connect(details: WiFiDetails) async throws {
        guard let interface = CWWiFiClient.shared().interface() else {
            throw NSError(domain: "WifiConnector", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Wi-Fi interface found"])
        }
        
        let networks = try interface.scanForNetworks(withSSID: details.ssid)
        guard let targetNetwork = networks.first else {
            throw NSError(domain: "WifiConnector", code: 2, userInfo: [NSLocalizedDescriptionKey: "Network '\(details.ssid)' not found in scan results"])
        }
        
        try interface.associate(to: targetNetwork, password: details.password)
    }
}
```

**Step 2: Commit**
```bash
git commit -m "feat: add CoreWLAN integration for connecting to Wi-Fi"
```

---

### Task 4: Create User Interface (SwiftUI)
Implement the sidebar layout, camera scanner view, and Wi-Fi info pane.

**Files:**
- Create: `Sources/WifiQrConnect/Views/MainView.swift`
- Create: `Sources/WifiQrConnect/Views/ScannerView.swift`
- Create: `Sources/WifiQrConnect/Views/WifiView.swift`
- Modify: `Sources/WifiQrConnect/main.swift`

**Step 1: Modify `main.swift` to launch `MainView`**
Set up the Window and assign `MainView()` as root content.

**Step 2: Implement `MainView.swift`**
A sidebar layout matching the original Flutter app:
```swift
struct MainView: View {
    @State private var selectedTab: Int = 0
    @State private var scannedWifi: WiFiDetails? = nil

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                Label("QR Scanner", systemImage: "qrcode.viewfinder").tag(0)
                Label("WiFi Info", systemImage: "wifi").tag(1)
            }
        } detail: {
            if selectedTab == 0 {
                ScannerView(scannedWifi: $scannedWifi, selectedTab: $selectedTab)
            } else {
                WifiView(wifiDetails: scannedWifi)
            }
        }
    }
}
```

**Step 3: Implement `ScannerView.swift`**
Uses `AVCaptureSession` and `AVCaptureMetadataOutput` with `.qr` types to read QR codes. When a QR is successfully parsed:
1. Update `scannedWifi` binding.
2. Direct navigation to `selectedTab = 1` (Wifi view).

**Step 4: Implement `WifiView.swift`**
Displays details dynamically (SSID, Password hidden by bullets, Security). Includes a "Connect to Network" button that calls `WifiConnector.connect()`.

**Step 5: Run compile and test**
Run: `Scripts/compile_and_run.sh`
Expected: Full app runs with functional navigation, camera permission request, and scanning.

**Step 6: Commit**
```bash
git commit -m "feat: add SwiftUI views and navigation layout"
```

---

### Task 5: Clean up Flutter codebase
Remove Flutter directories now that the application is natively built in Swift.

**Files:**
- Modify: `.gitignore` (remove Flutter artifacts, add build/ and Xcode artifacts)
- Delete: `lib/`, `macos/`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`

**Step 1: Clean directories**
```bash
rm -rf lib/ macos/ pubspec.yaml pubspec.lock analysis_options.yaml build/
```

**Step 2: Commit cleanup**
```bash
git commit -m "cleanup: remove legacy Flutter project files"
```
