# Plan: Phase 2 — Saved Networks (History) Tab

**Goal:** Implement a history persistence layer and a dedicated SwiftUI "History" tab that lists previously scanned/connected networks, allowing the user to search, view passwords, delete history, and quickly reconnect.

---

### Task 1: Create the History Persistence Manager
Write a `HistoryManager` class to load and save Wi-Fi configurations in `UserDefaults` using standard Codable JSON serialization.

**Files:**
- Create: `Sources/WifiQrConnect/Services/HistoryManager.swift`
- Create: `Tests/WifiQrConnectTests/HistoryManagerTests.swift`

---

### Task 2: Build the History View
Implement a user interface in SwiftUI to list saved networks chronologically, provide SSID search filtering, show password toggles, and add "Connect" and "Delete" actions.

**Files:**
- Create: `Sources/WifiQrConnect/Views/HistoryView.swift`

---

### Task 3: Integrate with Connection Flows
Automatically save networks to the history log whenever a successful scan is processed or when the user successfully associates to a network.

**Files:**
- Modify: `Sources/WifiQrConnect/Views/ScannerView.swift`
- Modify: `Sources/WifiQrConnect/Views/WifiView.swift`

---

### Task 4: Integrate into Navigation Layout
Add the "History" option to the sidebar and route it to the new view.

**Files:**
- Modify: `Sources/WifiQrConnect/Views/MainView.swift`

---

### Verification Checklist
1. App compiles cleanly (`swift build`).
2. History unit tests pass (`swift test`).
3. Successful connections from scanner or manual WiFi view automatically add entries to the history tab.
4. History view allows filtering by SSID, toggling password visibility, one-click reconnecting, and removing entries.
