# Plan: Phase 3 — Settings & Customization

**Goal:** Implement app-wide settings management, including dark/light mode customization, beep sound toggling, and an "Auto-Connect" workflow that directly connects to scanned Wi-Fi networks without clicking through confirmation panes.

---

### Task 1: Create the Settings Manager
Write a `SettingsManager` class that manages app configurations backed by `UserDefaults`.

**Files:**
- Create: `Sources/WifiQrConnect/Services/SettingsManager.swift`
- Create: `Tests/WifiQrConnectTests/SettingsManagerTests.swift`

---

### Task 2: Build the Settings View
Create a SwiftUI user interface with toggles for Sound, Auto-Connect, and a picker for Theme selection (System, Light, Dark).

**Files:**
- Create: `Sources/WifiQrConnect/Views/SettingsView.swift`

---

### Task 3: Integrate Settings with Behaviors
1. **Beep sound**: Check `SettingsManager.shared.playBeep` before playing sounds in the scanner.
2. **Auto-Connect**: If `SettingsManager.shared.autoConnect` is enabled, bypass the "Wi-Fi Info" preview tab and immediately connect to the scanned network in the scanner view.
3. **Appearance**: Apply `.preferredColorScheme` to the main window based on the selected theme.

**Files:**
- Modify: `Sources/WifiQrConnect/Views/ScannerView.swift`
- Modify: `Sources/WifiQrConnect/main.swift`

---

### Task 4: Integrate into Navigation Layout
Add the "Settings" option to the sidebar and route it to the new view.

**Files:**
- Modify: `Sources/WifiQrConnect/Views/MainView.swift`

---

### Verification Checklist
1. App compiles cleanly (`swift build`).
2. Settings unit tests pass (`swift test`).
3. Changing the theme dynamically updates the app's appearance (Light vs Dark).
4. Disabling "Play Beep Sound" silences the scanner.
5. Enabling "Auto-Connect" skips the WiFi Info screen and connects directly when a WiFi QR code is scanned.
