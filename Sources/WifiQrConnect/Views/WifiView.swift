import CoreLocation
import CoreWLAN
import SwiftUI
import UniformTypeIdentifiers

struct WifiView: View {
    @State private var ssid = ""
    @State private var password = ""
    @State private var security = "WPA"
    @State private var isHidden = false
    @State private var showPassword = false
    @State private var showInfoPopover = false
    @State private var generatedImage: NSImage? = nil
    @State private var isSavedToHistory = false
    @State private var isDetecting = false
    @State private var isCustomNetwork = false
    @State private var connectedSSID: String? = nil
    @ObservedObject private var locationManager = LocationManager.shared

    /// Options for security type
    let securityOptions = [
        ("WPA/WPA2/WPA3", "WPA"),
        ("WEP", "WEP"),
        ("Open (None)", "nopass"),
    ]

    private var qrPayload: String {
        let targetSSID = isCustomNetwork ? ssid : (connectedSSID ?? "")
        let escapedSSID = escape(targetSSID)
        let escapedPassword = escape(password)
        let hiddenSegment = isHidden ? "H:true;" : ""
        let passwordSegment = security == "nopass" ? "" : "P:\(escapedPassword);"
        return "WIFI:S:\(escapedSSID);T:\(security);\(passwordSegment)\(hiddenSegment);"
    }

    var body: some View {
        HStack(spacing: 40) {
            // Left Column: Configuration Form
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wi-Fi Info & Share")
                        .font(.title)
                        .fontWeight(.bold)

                    if isCustomNetwork {
                        Text("Generate a QR code for any network manually.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Share your currently connected Wi-Fi network.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    // Network SSID Display
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Network Name (SSID)")
                            .fontWeight(.semibold)
                            .font(.subheadline)

                        if isCustomNetwork {
                            TextField("Enter SSID", text: $ssid)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))
                        } else {
                            HStack {
                                if isDetecting {
                                    ProgressView()
                                        .controlSize(.small)
                                    Text("Detecting connected network...")
                                        .foregroundColor(.secondary)
                                        .font(.callout)
                                } else if let activeSSID = connectedSSID {
                                    Image(systemName: "wifi")
                                        .foregroundColor(.accentColor)
                                    Text(activeSSID)
                                        .font(.system(.headline, design: .monospaced))
                                } else {
                                    Image(systemName: "wifi.slash")
                                        .foregroundColor(.secondary)
                                    Text("No Connected Wi-Fi")
                                        .foregroundColor(.secondary)
                                        .font(.headline)
                                }

                                Spacer()

                                Button(action: detectCurrentWifi) {
                                    Image(systemName: "arrow.clockwise")
                                }
                                .disabled(isDetecting)
                                .help("Auto-detect current WiFi network")
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    // Security Selection
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Security Type")
                            .fontWeight(.semibold)
                            .font(.subheadline)

                        Picker("", selection: $security) {
                            ForEach(securityOptions, id: \.1) { option in
                                Text(option.0).tag(option.1)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(!isCustomNetwork && isSavedToHistory)
                    }

                    // Password Input
                    if security != "nopass" {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Password")
                                    .fontWeight(.semibold)
                                    .font(.subheadline)

                                Button(action: { showInfoPopover.toggle() }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.accentColor)
                                }
                                .buttonStyle(.plain)
                                .popover(isPresented: $showInfoPopover, arrowEdge: .trailing) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("How to get your Wi-Fi password:")
                                            .font(.headline)

                                        Text("1. Open **System Settings** > **Wi-Fi**.")
                                        Text("2. Click **Details...** next to your active network.")
                                        Text("3. Click on the dots next to **Password** to show or copy it.")
                                    }
                                    .padding()
                                    .frame(width: 300)
                                }
                            }

                            HStack {
                                if showPassword {
                                    TextField("Enter Password", text: $password)
                                        .textFieldStyle(.roundedBorder)
                                        .font(.system(.body, design: .monospaced))
                                } else {
                                    SecureField("Enter Password", text: $password)
                                        .textFieldStyle(.roundedBorder)
                                        .font(.system(.body, design: .monospaced))
                                }

                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .disabled(!isCustomNetwork && isSavedToHistory)
                        }
                    }

                    // Hidden Network Toggle (only in custom network mode)
                    if isCustomNetwork {
                        Toggle("Hidden Network", isOn: $isHidden)
                            .fontWeight(.semibold)
                            .font(.subheadline)
                            .toggleStyle(.checkbox)
                            .padding(.top, 4)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.windowBackgroundColor).opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                )

                // Details description & settings link for non-history network
                if !isCustomNetwork, connectedSSID != nil {
                    if isSavedToHistory {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.title3)

                            Text("Password loaded from history. Other devices can scan the QR code to connect instantly.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                )
                        )
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Password Not Found in History")
                                    .font(.headline)
                            }

                            Text("Since you connected to this Wi-Fi network manually, the password is not in this app's history and cannot be fetched automatically due to macOS Keychain restrictions. You have never connected to this network using this app before.")
                                .font(.callout)
                                .foregroundColor(.secondary)

                            Text("Please copy your password from macOS Wi-Fi settings and paste it above to generate the QR code.")
                                .font(.callout)
                                .foregroundColor(.secondary)

                            Button(action: {
                                let settingsURL = "x-apple.systempreferences:com.apple.Wi-Fi-Settings.extension"
                                if let url = URL(string: settingsURL) {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Label("Open Wi-Fi Settings to Copy Password", systemImage: "arrow.up.forward.app")
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.link)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }

                // History Actions
                let activeSSID = isCustomNetwork ? ssid : (connectedSSID ?? "")
                if !activeSSID.isEmpty {
                    if isSavedToHistory {
                        Button(action: removeFromHistory) {
                            Label("Remove Saved Password", systemImage: "trash")
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    } else if !password.isEmpty || security == "nopass" {
                        Button(action: saveToHistory) {
                            Label("Save to History & Share", systemImage: "checkmark.circle")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }

                Spacer()

                // Mode Toggle Button
                Button(action: {
                    isCustomNetwork.toggle()
                    if !isCustomNetwork {
                        detectCurrentWifi()
                    } else {
                        ssid = ""
                        password = ""
                        security = "WPA"
                        isHidden = false
                        isSavedToHistory = false
                        generatedImage = nil
                    }
                }) {
                    Text(isCustomNetwork ? "← Share Connected Wi-Fi" : "Generate custom Wi-Fi QR →")
                        .font(.callout)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.link)
            }
            .frame(maxWidth: 380)

            // Right Column: QR Code Preview
            VStack(spacing: 24) {
                Text("QR Code Sharing")
                    .font(.headline)
                    .foregroundColor(.secondary)

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .frame(width: 260, height: 260)

                    let targetSSID = isCustomNetwork ? ssid : (connectedSSID ?? "")
                    if !targetSSID.isEmpty {
                        if let image = generatedImage {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                                .padding(20)
                                .frame(width: 260, height: 260)
                        } else {
                            ProgressView()
                                .frame(width: 260, height: 260)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("Enter network name to generate QR Code")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(width: 260, height: 260)
                    }
                }

                let targetSSID = isCustomNetwork ? ssid : (connectedSSID ?? "")
                if let image = generatedImage, !targetSSID.isEmpty {
                    Button(action: { saveImage(image) }) {
                        Label("Save QR Image", systemImage: "square.and.arrow.down")
                            .fontWeight(.semibold)
                            .frame(width: 180)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(30)
        .onAppear {
            locationManager.requestAuthorization()
            detectCurrentWifi()
        }
        .onChange(of: locationManager.authorizationStatus) { _, _ in
            detectCurrentWifi()
        }
        .onChange(of: ssid) { _, newValue in
            if isCustomNetwork {
                checkHistoryStatus(for: newValue)
                regenerateQR()
            }
        }
        .onChange(of: password) { _, _ in
            regenerateQR()
        }
        .onChange(of: security) { _, _ in
            regenerateQR()
        }
        .onChange(of: isHidden) { _, _ in
            regenerateQR()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func detectCurrentWifi() {
        isDetecting = true
        Task {
            let detectedSSID = await Task.detached(priority: .userInitiated) { () -> String? in
                guard let interface = CWWiFiClient.shared().interface() else { return nil }
                return interface.ssid()
            }.value

            await MainActor.run {
                isDetecting = false
                if let ssidName = detectedSSID {
                    connectedSSID = ssidName
                    if !isCustomNetwork {
                        checkHistoryStatus(for: ssidName)
                    }
                } else {
                    connectedSSID = nil
                    if !isCustomNetwork {
                        isSavedToHistory = false
                        generatedImage = nil
                    }
                }
            }
        }
    }

    private func checkHistoryStatus(for targetSSID: String) {
        if let saved = HistoryManager.shared.networks.first(where: { $0.ssid == targetSSID }) {
            password = saved.password
            security = saved.security
            isHidden = saved.hidden
            isSavedToHistory = true
        } else {
            isSavedToHistory = false
            password = ""
            security = "WPA"
            isHidden = false
        }
        regenerateQR()
    }

    private func saveToHistory() {
        let targetSSID = isCustomNetwork ? ssid : (connectedSSID ?? "")
        guard !targetSSID.isEmpty else { return }

        HistoryManager.shared.add(
            ssid: targetSSID,
            password: password,
            security: security,
            hidden: isHidden
        )
        isSavedToHistory = true
    }

    private func removeFromHistory() {
        let targetSSID = isCustomNetwork ? ssid : (connectedSSID ?? "")
        guard !targetSSID.isEmpty else { return }

        if let saved = HistoryManager.shared.networks.first(where: { $0.ssid == targetSSID }) {
            HistoryManager.shared.remove(saved)
        }
        password = ""
        isSavedToHistory = false
        regenerateQR()
    }

    private func regenerateQR() {
        let targetSSID = isCustomNetwork ? ssid : (connectedSSID ?? "")
        guard !targetSSID.isEmpty else {
            generatedImage = nil
            return
        }
        if security != "nopass", password.isEmpty {
            generatedImage = nil
            return
        }
        generatedImage = QRGenerator.generate(from: qrPayload, size: CGSize(width: 300, height: 300))
    }

    private func escape(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ":", with: "\\:")
            .replacingOccurrences(of: ",", with: "\\,")
    }

    private func saveImage(_ image: NSImage) {
        let targetSSID = isCustomNetwork ? ssid : (connectedSSID ?? "")
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.nameFieldStringValue = "wifi_share_\(targetSSID.replacingOccurrences(of: " ", with: "_")).png"

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                guard let tiffData = image.tiffRepresentation,
                      let bitmapImage = NSBitmapImageRep(data: tiffData),
                      let pngData = bitmapImage.representation(using: .png, properties: [:])
                else {
                    return
                }

                do {
                    try pngData.write(to: url)
                } catch {
                    print("Error saving QR image: \(error.localizedDescription)")
                }
            }
        }
    }
}
