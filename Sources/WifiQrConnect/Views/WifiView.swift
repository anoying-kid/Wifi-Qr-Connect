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

    /// Options for security type
    let securityOptions = [
        ("WPA/WPA2/WPA3", "WPA"),
        ("WEP", "WEP"),
        ("Open (None)", "nopass"),
    ]

    private var qrPayload: String {
        let escapedSSID = escape(ssid)
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
                    Text("Share your connected Wi-Fi or generate a QR code for any network.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    // SSID Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Network Name (SSID)")
                            .fontWeight(.semibold)
                            .font(.subheadline)

                        HStack {
                            TextField("Enter SSID", text: $ssid)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))

                            Button(action: detectCurrentWifi) {
                                if isDetecting {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                }
                            }
                            .disabled(isDetecting)
                            .help("Auto-detect current WiFi network")
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
                        }
                    }

                    // Hidden Network Toggle
                    Toggle("Hidden Network", isOn: $isHidden)
                        .fontWeight(.semibold)
                        .font(.subheadline)
                        .toggleStyle(.checkbox)
                        .padding(.top, 4)
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

                // History Actions
                if !ssid.isEmpty {
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
                            Label("Save to History", systemImage: "checkmark.circle")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
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

                    if !ssid.isEmpty {
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

                if let image = generatedImage, !ssid.isEmpty {
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
            // Request location permission on load
            CLLocationManager().requestWhenInUseAuthorization()
            detectCurrentWifi()
        }
        .onChange(of: ssid) { _, newValue in
            checkHistoryStatus(for: newValue)
            regenerateQR()
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
                    ssid = ssidName
                    checkHistoryStatus(for: ssidName)
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
        }
    }

    private func saveToHistory() {
        guard !ssid.isEmpty else { return }
        HistoryManager.shared.add(
            ssid: ssid,
            password: password,
            security: security,
            hidden: isHidden
        )
        isSavedToHistory = true
    }

    private func removeFromHistory() {
        guard !ssid.isEmpty else { return }
        if let saved = HistoryManager.shared.networks.first(where: { $0.ssid == ssid }) {
            HistoryManager.shared.remove(saved)
        }
        password = ""
        isSavedToHistory = false
        regenerateQR()
    }

    private func regenerateQR() {
        guard !ssid.isEmpty else {
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
