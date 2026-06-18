import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared

    let themeOptions = ["System", "Light", "Dark"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Bar
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal, 30)
                .padding(.top, 30)
                .padding(.bottom, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Section: General Settings
                    VStack(alignment: .leading, spacing: 14) {
                        Text("General Settings")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)

                        VStack(alignment: .leading, spacing: 16) {
                            // Auto Connect Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Auto-Connect to Networks")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    Text("Bypasses confirmation and connects immediately upon scanning a WiFi QR.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: $settings.autoConnect)
                                    .toggleStyle(.switch)
                            }

                            Divider()

                            // Play Beep Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Play Scanner Sound")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    Text("Plays a subtle beep audio signal upon successful QR code detection.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: $settings.playBeep)
                                    .toggleStyle(.switch)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(NSColor.windowBackgroundColor).opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }

                    // Section: Appearance
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Appearance")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("App Theme")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    Text("Customize the visual theme of the application window.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Picker("", selection: $settings.theme) {
                                    ForEach(themeOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 200)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(NSColor.windowBackgroundColor).opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }

                    // Section: About
                    VStack(alignment: .leading, spacing: 14) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Application:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("WiFi QR Connect")
                                    .foregroundColor(.secondary)
                            }

                            Divider()

                            HStack {
                                Text("Version:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
                                    .foregroundColor(.secondary)
                            }

                            Divider()

                            HStack {
                                Text("Identifier:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("com.example.wifiqrconnect")
                                    .foregroundColor(.secondary)
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(NSColor.windowBackgroundColor).opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
