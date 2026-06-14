import CoreLocation
import CoreWLAN
import SwiftUI
import UniformTypeIdentifiers

struct WifiView: View {
    @StateObject private var locationAuthorizer = LocationAuthorizer()
    @State private var currentSSID: String? = nil
    @State private var enteredPassword = ""
    @State private var security = "WPA"
    @State private var showPassword = false
    @State private var showInfoPopover = false
    @State private var generatedImage: NSImage? = nil
    @State private var isSavedToHistory = false

    /// Options for security type
    let securityOptions = [
        ("WPA/WPA2/WPA3", "WPA"),
        ("WEP", "WEP"),
        ("Open (None)", "nopass"),
    ]

    private var qrPayload: String {
        guard let ssid = currentSSID else { return "" }
        let escapedSSID = escape(ssid)
        let escapedPassword = escape(enteredPassword)
        let passwordSegment = security == "nopass" ? "" : "P:\(escapedPassword);"
        return "WIFI:S:\(escapedSSID);T:\(security);\(passwordSegment);"
    }

    var body: some View {
        VStack(spacing: 0) {
            if let ssid = currentSSID {
                HStack(spacing: 40) {
                    // Left Column: Details & Input
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Active Wi-Fi Connection")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                                .textCase(.uppercase)

                            Text(ssid)
                                .font(.title)
                                .fontWeight(.bold)
                        }

                        if isSavedToHistory {
                            // Loaded from history status banner
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
                            // Keychain restriction alert
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("macOS Keychain Restriction")
                                        .font(.headline)
                                }

                                Text("macOS prevents apps from reading Wi-Fi passwords programmatically. Please enter the password below to generate a sharing QR code.")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
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
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            // Security Type Selection (only editable if not open)
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
                                .disabled(isSavedToHistory)
                            }

                            // Password Field (with Info Icon next to it)
                            if security != "nopass" {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Password")
                                            .fontWeight(.semibold)
                                            .font(.subheadline)

                                        if !isSavedToHistory {
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
                                    }

                                    HStack {
                                        if showPassword {
                                            TextField("Enter Password", text: $enteredPassword)
                                                .textFieldStyle(.roundedBorder)
                                                .font(.system(.body, design: .monospaced))
                                        } else {
                                            SecureField("Enter Password", text: $enteredPassword)
                                                .textFieldStyle(.roundedBorder)
                                                .font(.system(.body, design: .monospaced))
                                        }

                                        Button(action: { showPassword.toggle() }) {
                                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                                .foregroundColor(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .disabled(isSavedToHistory)
                                }
                            }
                        }

                        if !isSavedToHistory && !enteredPassword.isEmpty {
                            Button(action: saveToHistory) {
                                Label("Save to History", systemImage: "checkmark.circle")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        } else if isSavedToHistory {
                            Button(action: removeFromHistory) {
                                Label("Remove Saved Password", systemImage: "trash")
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }

                        Spacer()
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

                            if let image = generatedImage {
                                Image(nsImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(20)
                                    .frame(width: 260, height: 260)
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "qrcode")
                                        .font(.system(size: 48))
                                        .foregroundColor(.secondary.opacity(0.5))
                                    Text("Enter Wi-Fi password to generate QR Code")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .frame(width: 260, height: 260)
                            }
                        }

                        if let image = generatedImage {
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
            } else {
                // No connected network view
                VStack(spacing: 20) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)

                    Text("No Connected Wi-Fi")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Connect to a Wi-Fi network in your Mac's System Settings to share it.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)

                    Button("Open Wi-Fi Settings") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.wifi") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            locationAuthorizer.requestPermission()
            detectCurrentWifi()
        }
        .onChange(of: locationAuthorizer.isAuthorized) { _, _ in
            detectCurrentWifi()
        }
        .onChange(of: enteredPassword) { _, _ in
            regenerateQR()
        }
        .onChange(of: security) { _, _ in
            regenerateQR()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func detectCurrentWifi() {
        if let interface = CWWiFiClient.shared().interface(),
           let ssid = interface.ssid()
        {
            currentSSID = ssid

            // Check if this network is saved in history
            if let saved = HistoryManager.shared.networks.first(where: { $0.ssid == ssid }) {
                enteredPassword = saved.password
                security = saved.security
                isSavedToHistory = true
            } else {
                enteredPassword = ""
                security = "WPA"
                isSavedToHistory = false
            }
            regenerateQR()
        } else {
            currentSSID = nil
            enteredPassword = ""
            isSavedToHistory = false
            generatedImage = nil
        }
    }

    private func saveToHistory() {
        guard let ssid = currentSSID else { return }
        HistoryManager.shared.add(
            ssid: ssid,
            password: enteredPassword,
            security: security,
            hidden: false
        )
        isSavedToHistory = true
    }

    private func removeFromHistory() {
        guard let ssid = currentSSID else { return }
        if let saved = HistoryManager.shared.networks.first(where: { $0.ssid == ssid }) {
            HistoryManager.shared.remove(saved)
        }
        enteredPassword = ""
        isSavedToHistory = false
        regenerateQR()
    }

    private func regenerateQR() {
        guard let ssid = currentSSID, !ssid.isEmpty else {
            generatedImage = nil
            return
        }
        if security != "nopass", enteredPassword.isEmpty {
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
        guard let ssid = currentSSID else { return }
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.nameFieldStringValue = "wifi_share_\(ssid.replacingOccurrences(of: " ", with: "_")).png"

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
