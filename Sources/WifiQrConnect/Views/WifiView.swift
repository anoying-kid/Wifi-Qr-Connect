import SwiftUI

struct WifiView: View {
    let wifiDetails: WiFiDetails?
    
    @State private var isConnecting = false
    @State private var connectionError: String? = nil
    @State private var showSuccess = false
    @State private var showPassword = false
    
    var body: some View {
        VStack {
            if let details = wifiDetails {
                VStack(spacing: 24) {
                    Image(systemName: "wifi")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                        .symbolEffect(.bounce, value: isConnecting)
                    
                    Text("Wi-Fi Details")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Label("SSID:", systemImage: "network")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(details.ssid)
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        Divider()
                        
                        HStack {
                            Label("Password:", systemImage: "lock")
                                .fontWeight(.semibold)
                            Spacer()
                            if details.password.isEmpty {
                                Text("No password (Open)")
                                    .foregroundColor(.secondary)
                            } else {
                                HStack(spacing: 8) {
                                    if showPassword {
                                        Text(details.password)
                                            .font(.system(.body, design: .monospaced))
                                    } else {
                                        Text(String(repeating: "•", count: 8))
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
                        
                        Divider()
                        
                        HStack {
                            Label("Security:", systemImage: "shield")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(details.security.uppercased())
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        if details.hidden {
                            Divider()
                            HStack {
                                Label("Hidden Network:", systemImage: "eye.slash")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("Yes")
                                    .foregroundColor(.secondary)
                            }
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
                    .frame(maxWidth: 400)
                    
                    Spacer().frame(height: 20)
                    
                    if isConnecting {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Connecting to \(details.ssid)...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button(action: {
                            connectToWifiNetwork(details: details)
                        }) {
                            Text("Connect to Network")
                                .fontWeight(.semibold)
                                .frame(width: 200)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .padding()
                .alert("Connection Successful", isPresented: $showSuccess) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Successfully connected to \(details.ssid)!")
                }
                .alert("Connection Failed", isPresented: Binding(
                    get: { connectionError != nil },
                    set: { if !$0 { connectionError = nil } }
                )) {
                    Button("OK", role: .cancel) { }
                } message: {
                    if let error = connectionError {
                        Text(error)
                    }
                }
                
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("No Wi-Fi Scanned Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("Go to the QR Scanner tab and scan a Wi-Fi QR code to view and connect.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func connectToWifiNetwork(details: WiFiDetails) {
        isConnecting = true
        connectionError = nil
        
        Task {
            do {
                try await WifiConnector.connect(details: details)
                isConnecting = false
                showSuccess = true
                
                // Log successful connection to scan history
                HistoryManager.shared.add(
                    ssid: details.ssid,
                    password: details.password,
                    security: details.security,
                    hidden: details.hidden
                )
            } catch {
                isConnecting = false
                connectionError = error.localizedDescription
            }
        }
    }
}
