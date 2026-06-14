import SwiftUI

struct HistoryView: View {
    @ObservedObject var history = HistoryManager.shared
    @State private var searchText = ""
    @State private var expandedNetworkId: UUID? = nil

    // Connection states
    @State private var connectingNetworkId: UUID? = nil
    @State private var connectionError: String? = nil
    @State private var showSuccess = false
    @State private var successSSID = ""
    @State private var showPasswordMap: [UUID: Bool] = [:]

    var filteredNetworks: [SavedNetwork] {
        if searchText.isEmpty {
            return history.networks
        } else {
            return history.networks.filter { $0.ssid.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Text("Scan History")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                if !history.networks.isEmpty {
                    Button(role: .destructive, action: {
                        history.clearAll()
                    }) {
                        Label("Clear All", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)
            .padding(.bottom, 15)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search networks by name...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 30)
            .padding(.bottom, 15)

            if filteredNetworks.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: history.networks.isEmpty ? "clock.arrow.circlepath" : "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(history.networks.isEmpty ? "No History Yet" : "No Results Found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(history.networks.isEmpty ? "WiFi networks you scan or connect to will appear here." : "Try adjusting your search query.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredNetworks) { network in
                        HistoryRowView(
                            network: network,
                            isExpanded: expandedNetworkId == network.id,
                            isConnecting: connectingNetworkId == network.id,
                            showPassword: showPasswordMap[network.id, default: false],
                            onToggleExpand: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    if expandedNetworkId == network.id {
                                        expandedNetworkId = nil
                                    } else {
                                        expandedNetworkId = network.id
                                    }
                                }
                            },
                            onTogglePassword: {
                                showPasswordMap[network.id] = !(showPasswordMap[network.id] ?? false)
                            },
                            onConnect: {
                                connectToNetwork(network)
                            },
                            onDelete: {
                                history.remove(network)
                            }
                        )
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.inset)
                .padding(.horizontal, 15)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Connection Successful", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Successfully connected to \(successSSID)!")
        }
        .alert("Connection Failed", isPresented: Binding(
            get: { connectionError != nil },
            set: { if !$0 { connectionError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = connectionError {
                Text(error)
            }
        }
    }

    private func connectToNetwork(_ network: SavedNetwork) {
        connectingNetworkId = network.id
        connectionError = nil

        Task {
            do {
                try await WifiConnector.connect(details: network.wifiDetails)
                connectingNetworkId = nil
                successSSID = network.ssid
                showSuccess = true

                // Refresh scan history date
                history.add(ssid: network.ssid, password: network.password, security: network.security, hidden: network.hidden)
            } catch {
                connectingNetworkId = nil
                connectionError = error.localizedDescription
            }
        }
    }
}

// MARK: - Row Subview

struct HistoryRowView: View {
    let network: SavedNetwork
    let isExpanded: Bool
    let isConnecting: Bool
    let showPassword: Bool

    let onToggleExpand: () -> Void
    let onTogglePassword: () -> Void
    let onConnect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Image(systemName: network.security == "nopass" ? "wifi" : "wifi.lock")
                    .font(.title3)
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(network.ssid)
                        .font(.headline)
                        .fontWeight(.medium)

                    Text(formatDate(network.dateScanned))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button(action: onToggleExpand) {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Delete from history")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onToggleExpand)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Security Type")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(network.security.uppercased())
                                .font(.subheadline)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Hidden Network")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(network.hidden ? "Yes" : "No")
                                .font(.subheadline)
                        }
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if network.password.isEmpty {
                                Text("No password (Open)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                HStack(spacing: 8) {
                                    if showPassword {
                                        Text(network.password)
                                            .font(.system(.subheadline, design: .monospaced))
                                    } else {
                                        Text(String(repeating: "•", count: 8))
                                            .font(.system(.subheadline, design: .monospaced))
                                    }

                                    Button(action: onTogglePassword) {
                                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        Spacer()

                        if isConnecting {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Button(action: onConnect) {
                                Text("Connect")
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.opacity)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
