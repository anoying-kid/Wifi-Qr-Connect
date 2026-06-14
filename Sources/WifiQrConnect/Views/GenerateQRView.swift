import CoreLocation
import CoreWLAN
import SwiftUI
import UniformTypeIdentifiers

struct GenerateQRView: View {
    @StateObject private var locationAuthorizer = LocationAuthorizer()
    @State private var ssid = ""
    @State private var password = ""
    @State private var security = "WPA" // WPA, WEP, nopass
    @State private var isHidden = false

    @State private var showPassword = false
    @State private var generatedImage: NSImage? = nil

    let securityOptions = [
        ("WPA/WPA2/WPA3", "WPA"),
        ("WEP", "WEP"),
        ("Open (None)", "nopass"),
    ]

    var qrPayload: String {
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
                Text("Generate WiFi QR Code")
                    .font(.title)
                    .fontWeight(.bold)

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

                            Button(action: detectCurrentSSID) {
                                Image(systemName: "arrow.clockwise")
                            }
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
                            Text("Password")
                                .fontWeight(.semibold)
                                .font(.subheadline)

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

                Spacer()
            }
            .frame(maxWidth: 380)

            // Right Column: QR Preview and Save Options
            VStack(spacing: 24) {
                Text("QR Code Preview")
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
                            Text("Enter network name to generate")
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
                        Label("Save QR Code Image", systemImage: "square.and.arrow.down")
                            .fontWeight(.semibold)
                            .frame(width: 200)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    Button(action: {}) {}
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(true)
                        .hidden()
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(30)
        .onAppear {
            locationAuthorizer.requestPermission()
            detectCurrentSSID()
        }
        .onChange(of: locationAuthorizer.isAuthorized) { _, _ in
            detectCurrentSSID()
        }
        .onChange(of: qrPayload) { _, _ in
            regenerateQR()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func detectCurrentSSID() {
        if let interface = CWWiFiClient.shared().interface(),
           let currentSSID = interface.ssid()
        {
            ssid = currentSSID
            // Attempt to determine security type from hardware if connected
            // (default to WPA as most secure standard setup)
            security = "WPA"
            regenerateQR()
        }
    }

    private func regenerateQR() {
        guard !ssid.isEmpty else {
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
        savePanel.nameFieldStringValue = "wifi_qr_\(ssid.replacingOccurrences(of: " ", with: "_")).png"

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
