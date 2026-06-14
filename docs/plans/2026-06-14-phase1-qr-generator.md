# Plan: Phase 1 — Native QR Code Generator

**Goal:** Implement a native, dependency-free QR code generation service using CoreImage, auto-detect the current WiFi SSID, and build the "Generate QR" interface with options to save the QR code image.

---

### Task 1: Create the Native QR Generator Service
Write a helper service to turn raw strings into crisp, high-resolution `NSImage` instances using macOS's built-in CIFilters.

**Files:**
- Create: `Sources/WifiQrConnect/Services/QRGenerator.swift`
- Create: `Tests/WifiQrConnectTests/QRGeneratorTests.swift`

---

### Task 2: Build the Generate QR View
Implement a user input form in SwiftUI to capture WiFi configurations (SSID, Password, Security, Hidden status) and render the QR code in real-time.

**Files:**
- Create: `Sources/WifiQrConnect/Views/GenerateQRView.swift`

---

### Task 3: Integrate into Navigation Layout
Add the "Generate QR" option to the sidebar and route it to the new view.

**Files:**
- Modify: `Sources/WifiQrConnect/Views/MainView.swift`

---

### Verification Checklist
1. App compiles cleanly (`swift build`).
2. Generator unit tests pass (`swift test`).
3. Running the app (`Scripts/compile_and_run.sh`) opens the interface, displays "Generate QR" in the sidebar, correctly auto-populates the current active WiFi network name, updates the QR code as password/settings change, and successfully saves the image via `NSSavePanel`.
