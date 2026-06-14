@preconcurrency import AVFoundation
import CoreMedia
import CoreVideo
import SwiftUI
import Vision

struct ScannerView: View {
    @State private var pendingWifi: WiFiDetails? = nil

    @State private var scannedText: String? = nil
    @State private var isScanning = true
    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined

    // Alert state for links/text
    @State private var showingLinkAlert = false
    @State private var showingTextAlert = false
    @State private var alertPayload = ""

    // Auto-connection states
    @State private var isConnecting = false
    @State private var connectionError: String? = nil
    @State private var showSuccess = false
    @State private var successSSID = ""

    var body: some View {
        VStack {
            if cameraPermission == .authorized {
                VStack(spacing: 24) {
                    ZStack {
                        CameraScannerView(scannedText: $scannedText, isScanning: $isScanning)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentColor, lineWidth: 2)
                                    .opacity(0.8)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                            .frame(width: 400, height: 400)

                        if isScanning {
                            ScannerOverlayView()
                                .frame(width: 400, height: 400)
                        }

                        if isConnecting {
                            Color.black.opacity(0.6)
                                .cornerRadius(16)
                                .overlay(
                                    VStack(spacing: 12) {
                                        ProgressView()
                                        Text("Auto-Connecting...")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                )
                                .frame(width: 400, height: 400)
                        }

                        if let pending = pendingWifi {
                            Color.black.opacity(0.5)
                                .cornerRadius(16)
                                .frame(width: 400, height: 400)

                            VStack(spacing: 16) {
                                Image(systemName: "wifi")
                                    .font(.system(size: 40))
                                    .foregroundColor(.accentColor)

                                Text("Connect to Wi-Fi?")
                                    .font(.headline)

                                Text(pending.ssid)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .lineLimit(1)

                                Text("Security: \(pending.security.uppercased())")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 16) {
                                    Button("Cancel", role: .cancel) {
                                        pendingWifi = nil
                                        resetScanner()
                                    }
                                    .buttonStyle(.bordered)
                                    .keyboardShortcut(.cancelAction)

                                    Button("Connect") {
                                        let details = pending
                                        pendingWifi = nil
                                        autoConnectToWifi(details: details)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(NSColor.windowBackgroundColor))
                                    .shadow(radius: 10)
                            )
                            .frame(width: 320)
                        }
                    }

                    Text("Align a Wi-Fi QR code within the frame to connect.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .padding()

            } else if cameraPermission == .notDetermined {
                VStack(spacing: 20) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)

                    Text("Camera Access Required")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("This app needs camera access to scan Wi-Fi QR codes.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)

                    Button("Grant Permission") {
                        requestCameraPermission()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()

            } else {
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill.badge.ellipsis")
                        .font(.system(size: 64))
                        .foregroundColor(.red)

                    Text("Camera Access Denied")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Please enable camera access for WifiQrConnect in System Settings > Privacy & Security > Camera.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)

                    Button("Open System Settings") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding()
            }
        }
        .onAppear {
            checkCameraPermission()
        }
        .onChange(of: scannedText) { _, newValue in
            if let newValue = newValue {
                handleScannedCode(newValue)
            }
        }
        .sheet(isPresented: $showingLinkAlert) {
            LinkPromptView(urlStr: alertPayload) {
                if let url = URL(string: alertPayload) {
                    NSWorkspace.shared.open(url)
                }
                showingLinkAlert = false
                resetScanner()
            } onCancel: {
                showingLinkAlert = false
                resetScanner()
            }
        }
        .sheet(isPresented: $showingTextAlert) {
            TextPromptView(text: alertPayload) {
                let query = alertPayload.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "https://www.google.com/search?q=\(query)") {
                    NSWorkspace.shared.open(url)
                }
                showingTextAlert = false
                resetScanner()
            } onCancel: {
                showingTextAlert = false
                resetScanner()
            }
        }
        .alert("Connection Successful", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                resetScanner()
            }
        } message: {
            Text("Successfully connected to \(successSSID)!")
        }
        .alert("Connection Failed", isPresented: Binding(
            get: { connectionError != nil },
            set: { if !$0 { connectionError = nil } }
        )) {
            Button("OK", role: .cancel) {
                resetScanner()
            }
        } message: {
            if let error = connectionError {
                Text(error)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func checkCameraPermission() {
        cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraPermission == .notDetermined {
            requestCameraPermission()
        }
    }

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermission = granted ? .authorized : .denied
            }
        }
    }

    private func handleScannedCode(_ code: String) {
        if SettingsManager.shared.playBeep {
            NSSound.beep()
        }

        if code.hasPrefix("WIFI:") {
            if let details = QRParser.parse(qrString: code) {
                // Save scanned network to history
                HistoryManager.shared.add(
                    ssid: details.ssid,
                    password: details.password,
                    security: details.security,
                    hidden: details.hidden
                )

                if SettingsManager.shared.autoConnect {
                    autoConnectToWifi(details: details)
                } else {
                    pendingWifi = details
                }
            } else {
                alertPayload = code
                showingTextAlert = true
            }
        } else if code.hasPrefix("http://") || code.hasPrefix("https://") {
            alertPayload = code
            showingLinkAlert = true
        } else {
            alertPayload = code
            showingTextAlert = true
        }
    }

    private func autoConnectToWifi(details: WiFiDetails) {
        isConnecting = true
        connectionError = nil

        Task {
            do {
                try await WifiConnector.connect(details: details)
                isConnecting = false
                successSSID = details.ssid
                showSuccess = true
            } catch {
                isConnecting = false
                connectionError = error.localizedDescription
            }
        }
    }

    private func resetScanner() {
        scannedText = nil
        isScanning = true
    }
}

// MARK: - Camera Scanner View

struct CameraScannerView: NSViewRepresentable {
    @Binding var scannedText: String?
    @Binding var isScanning: Bool

    @MainActor
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraScannerView
        var session: AVCaptureSession?

        init(parent: CameraScannerView) {
            self.parent = parent
        }

        nonisolated func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            let request = VNDetectBarcodesRequest()
            request.symbologies = [.qr]

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([request])
                if let results = request.results,
                   let firstQR = results.first(where: { $0.symbology == .qr }),
                   let payload = firstQR.payloadStringValue
                {
                    Task { @MainActor in
                        guard self.parent.isScanning else { return }
                        self.parent.scannedText = payload
                        self.parent.isScanning = false

                        let session = self.session
                        DispatchQueue.global(qos: .userInitiated).async {
                            session?.stopRunning()
                        }
                    }
                }
            } catch {
                // Ignore errors and continue to next frame
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        let session = AVCaptureSession()
        context.coordinator.session = session

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return view }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return view
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            return view
        }

        let videoDataOutput = AVCaptureVideoDataOutput()

        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            let videoQueue = DispatchQueue(label: "com.example.wifiqrconnect.videoQueue", qos: .userInteractive)
            videoDataOutput.setSampleBufferDelegate(context.coordinator, queue: videoQueue)
        } else {
            return view
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.wantsLayer = true
        view.layer = previewLayer

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        return view
    }

    func updateNSView(_: NSView, context: Context) {
        let session = context.coordinator.session
        let scanning = isScanning
        DispatchQueue.global(qos: .userInitiated).async {
            if let session = session {
                if scanning {
                    if !session.isRunning {
                        session.startRunning()
                    }
                } else {
                    if session.isRunning {
                        session.stopRunning()
                    }
                }
            }
        }
    }

    static func dismantleNSView(_: NSView, coordinator: Coordinator) {
        let session = coordinator.session
        DispatchQueue.global(qos: .userInitiated).async {
            if let session = session, session.isRunning {
                session.stopRunning()
            }
        }
    }
}

// MARK: - Viewfinder Overlay

struct ScannerOverlayView: View {
    @State private var scanPosition: CGFloat = -180

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BracketsShape()
                    .stroke(Color.accentColor, lineWidth: 4)
                    .opacity(0.8)

                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, Color.accentColor, .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 3)
                    .shadow(color: Color.accentColor.opacity(0.8), radius: 6, x: 0, y: 0)
                    .offset(y: scanPosition)
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 2.5)
                                .repeatForever(autoreverses: true)
                        ) {
                            scanPosition = geometry.size.height / 2 - 15
                        }
                    }
            }
        }
    }
}

struct BracketsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 30
        let gap: CGFloat = 5

        // Top Left
        path.move(to: CGPoint(x: rect.minX + gap, y: rect.minY + gap + length))
        path.addLine(to: CGPoint(x: rect.minX + gap, y: rect.minY + gap))
        path.addLine(to: CGPoint(x: rect.minX + gap + length, y: rect.minY + gap))

        // Top Right
        path.move(to: CGPoint(x: rect.maxX - gap - length, y: rect.minY + gap))
        path.addLine(to: CGPoint(x: rect.maxX - gap, y: rect.minY + gap))
        path.addLine(to: CGPoint(x: rect.maxX - gap, y: rect.minY + gap + length))

        // Bottom Right
        path.move(to: CGPoint(x: rect.maxX - gap, y: rect.maxY - gap - length))
        path.addLine(to: CGPoint(x: rect.maxX - gap, y: rect.maxY - gap))
        path.addLine(to: CGPoint(x: rect.maxX - gap - length, y: rect.maxY - gap))

        // Bottom Left
        path.move(to: CGPoint(x: rect.minX + gap + length, y: rect.maxY - gap))
        path.addLine(to: CGPoint(x: rect.minX + gap, y: rect.maxY - gap))
        path.addLine(to: CGPoint(x: rect.minX + gap, y: rect.maxY - gap - length))

        return path
    }
}

// MARK: - Sheets

struct LinkPromptView: View {
    let urlStr: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "safari")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("Open Link?")
                .font(.headline)

            Text("Scanned URL:")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(urlStr)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal)

            HStack(spacing: 12) {
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button("Open Safari") {
                    onConfirm()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 320, height: 220)
    }
}

struct TextPromptView: View {
    let text: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("Search Google?")
                .font(.headline)

            Text("Scanned Content:")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal)

            HStack(spacing: 12) {
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button("Search Google") {
                    onConfirm()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 320, height: 220)
    }
}
