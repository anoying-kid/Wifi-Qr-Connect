import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

enum QrDetail { wifi, link, text }

enum ConnectionStatus { connecting, success, failed }

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner>
    with WidgetsBindingObserver {
  final MobileScannerController cameraController = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  StreamSubscription<BarcodeCapture>? _subscription;
  bool _isCameraLoading = true;
  bool _isDisposed = false;

  // Add these new state variables
  ConnectionStatus? _connectionStatus;
  String? _connectionMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = cameraController.barcodes.listen(_handleBarcode);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _startCamera();
      }
    });
  }

  Future<void> _startCamera() async {
    if (_isDisposed) return;

    if (mounted) {
      setState(() => _isCameraLoading = true);
    }

    try {
      await cameraController.start();
    } on MobileScannerException catch (e) {
      debugPrint(
          'MobileScannerException while starting: ${e.errorCode} ${e.toString()}');
      if (!_isDisposed && mounted) {
        await FlutterPlatformAlert.showCustomAlert(
          windowTitle: 'Camera error',
          text: 'Failed to start camera: ${e.toString()}',
          positiveButtonTitle: 'OK',
        );
      }
    } catch (e) {
      debugPrint('Unexpected error starting camera: $e');
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isCameraLoading = false);
      }
    }
  }

  // barcode stream handler
  void _handleBarcode(BarcodeCapture capture) {
    if (_isDisposed || !mounted) return;

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        // stop camera to avoid duplicate handling and show prompt
        cameraController.stop();
        qrChecker(barcode.rawValue!, context);
        break; // handle only the first barcode in a capture
      }
    }
  }

  // --- your existing helpers (unchanged, tweaked for safety) ---
  Map<String, String> getWifiDetails(String code) {
    final sIndex = code.indexOf('S:');
    final tIndex = code.indexOf(';T');
    final pIndex = code.indexOf('P:');
    final hIndex = code.indexOf(';H');

    final ssid = (sIndex >= 0 && tIndex > sIndex)
        ? code.substring(sIndex + 2, tIndex)
        : '';
    final password = (pIndex >= 0 && hIndex > pIndex)
        ? code.substring(pIndex + 2, hIndex)
        : '';
    return {'ssid': ssid, 'password': password};
  }

  // Enhanced WiFi connection with feedback
  Future<void> connectToWifi(String ssid, String password) async {
    if (_isDisposed || !mounted) return;

    setState(() {
      _connectionStatus = ConnectionStatus.connecting;
      _connectionMessage = 'Connecting to $ssid...';
    });

    try {
      // Turn on WiFi first
      final powerResult =
          await Process.run('networksetup', ['-setairportpower', 'en0', 'on']);

      if (powerResult.exitCode != 0) {
        throw Exception('Failed to turn on WiFi: ${powerResult.stderr}');
      }

      // Wait a moment for WiFi to power on
      await Future.delayed(const Duration(seconds: 1));

      // Connect to network
      final connectResult = await Process.run(
          'networksetup', ['-setairportnetwork', 'en0', ssid, password]);

      if (connectResult.exitCode != 0) {
        throw Exception('Failed to connect: ${connectResult.stderr}');
      }

      // Verify connection by checking current network
      await Future.delayed(const Duration(seconds: 2));
      final currentNetwork = await _getCurrentNetwork();

      setState(() {
        _connectionStatus = ConnectionStatus.success;
        _connectionMessage =
            currentNetwork?.toLowerCase().contains(ssid.toLowerCase()) == true
                ? 'Successfully connected to $ssid!'
                : 'Connection command sent to $ssid';
      });

      // Show success dialog
      await _showConnectionResult(true, ssid);
    } catch (e) {
      debugPrint('WiFi connection error: $e');
      setState(() {
        _connectionStatus = ConnectionStatus.failed;
        _connectionMessage = 'Failed to connect to $ssid: ${e.toString()}';
      });

      await _showConnectionResult(false, ssid, error: e.toString());
    } finally {
      if (mounted && !_isDisposed) {
        // Clear connection status after a delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !_isDisposed) {
            setState(() {
              _connectionStatus = null;
              _connectionMessage = null;
            });
          }
        });
      }
    }
  }

  void browserSearch(String code) async {
    await Process.run('open', [code]);
  }

  Future<String?> _getCurrentNetwork() async {
    try {
      final result =
          await Process.run('networksetup', ['-getairportnetwork', 'en0']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        // Extract network name from output like "Current Wi-Fi Network: MyNetwork"
        final match =
            RegExp(r'Current Wi-Fi Network:\s*(.+)').firstMatch(output);
        return match?.group(1)?.trim();
      }
    } catch (e) {
      debugPrint('Error getting current network: $e');
    }
    return null;
  }

  Future<void> _showConnectionResult(bool success, String ssid,
      {String? error}) async {
    if (_isDisposed || !mounted) return;

    await FlutterPlatformAlert.showCustomAlert(
      windowTitle: success ? 'Connection Successful' : 'Connection Failed',
      text: success
          ? 'You have been connected to "$ssid"'
          : 'Failed to connect to "$ssid"\n\nError: $error',
      positiveButtonTitle: 'OK',
    );
  }

  // Enhanced QR checker
  void qrChecker(String code, BuildContext context) async {
    if (_isDisposed || !mounted) return;

    String windowTitle = code;
    late String pBTitle;
    late QrDetail qrState;
    await FlutterPlatformAlert.playAlertSound();

    if (code.startsWith('WIFI:S:')) {
      qrState = QrDetail.wifi;
      final wifiDetails = getWifiDetails(code);
      windowTitle = "Connect to ${wifiDetails['ssid']}?";
      pBTitle = 'Connect to WiFi';
    } else if (code.startsWith('http')) {
      qrState = QrDetail.link;
      pBTitle = 'Open Link';
    } else {
      qrState = QrDetail.text;
      pBTitle = "Search Google";
    }

    final clickedButton = await FlutterPlatformAlert.showCustomAlert(
      windowTitle: windowTitle,
      text: _getAlertText(code, qrState),
      positiveButtonTitle: pBTitle,
      negativeButtonTitle: "Cancel",
    );

    if (_isDisposed || !mounted) return;

    switch (clickedButton) {
      case CustomButton.positiveButton:
        await qrCodeRunner(qrState, code);
        // Don't pop immediately - let user see the result
        if (qrState != QrDetail.wifi && context.mounted) {
          cameraController.start();
        }
        break;
      default:
        if (!_isDisposed) {
          cameraController.start();
        }
        break;
    }
  }

  String _getAlertText(String code, QrDetail qrState) {
    switch (qrState) {
      case QrDetail.wifi:
        final wifiDetails = getWifiDetails(code);
        return 'Network: ${wifiDetails['ssid']}\n'
            'Password: ${wifiDetails['password']!.isNotEmpty ? '••••••••' : 'No password'}\n\n'
            'This will connect your Mac to this WiFi network.';
      case QrDetail.link:
        return 'Open this link in your browser?';
      case QrDetail.text:
        return 'Search Google for this text?';
    }
  }

  // Enhanced QR code runner
  Future<void> qrCodeRunner(QrDetail qrState, String code) async {
    switch (qrState) {
      case QrDetail.link:
        browserSearch(code);
        break;
      case QrDetail.wifi:
        final wifiDetails = getWifiDetails(code);
        await connectToWifi(wifiDetails['ssid']!, wifiDetails['password']!);
        break;
      case QrDetail.text:
        browserSearch(
            "https://google.com/search?q=${Uri.encodeComponent(code)}");
        break;
    }
  }

  // Enhanced build method with connection status overlay
  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('QR Scanner'),
        titleWidth: 150.0,
      ),
      children: [
        ContentArea(builder: (context, scrollController) {
          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: (_) {},
              ),

              if (_isCameraLoading) const Center(child: ProgressCircle()),

              // Connection status overlay
              if (_connectionStatus != null)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: MacosAlertDialog(
                      primaryButton: const PushButton(
                        controlSize: ControlSize.large,
                        onPressed: null,
                        child: Text('Connecting...'),
                      ),
                      secondaryButton: PushButton(
                        controlSize: ControlSize.large,
                        child: Text(
                            _connectionStatus == ConnectionStatus.success
                                ? 'Done'
                                : 'OK'),
                        onPressed: () {
                          setState(() {
                            _connectionStatus = null;
                            _connectionMessage = null;
                          });
                          if (context.mounted) {
                            cameraController.start();
                          }
                        },
                      ),
                      appIcon: _getConnectionIcon(),
                      title: Text(_getConnectionTitle()),
                      message: Text(_connectionMessage ?? ''),
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _getConnectionIcon() {
    switch (_connectionStatus) {
      case ConnectionStatus.connecting:
        return const ProgressCircle();
      case ConnectionStatus.success:
        return const MacosIcon(CupertinoIcons.checkmark_alt_circle_fill);
      case ConnectionStatus.failed:
        return const MacosIcon(CupertinoIcons.xmark_circle_fill);
      default:
        return const SizedBox();
    }
  }

  String _getConnectionTitle() {
    switch (_connectionStatus) {
      case ConnectionStatus.connecting:
        return 'Connecting to WiFi';
      case ConnectionStatus.success:
        return 'Connected!';
      case ConnectionStatus.failed:
        return 'Connection Failed';
      default:
        return '';
    }
  }

  // ... keep your existing dispose, didChangeAppLifecycleState methods
  //   // --- app lifecycle handling ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    // Guard: permission dialogs may trigger lifecycle changes before permissions resolved.
    if (!cameraController.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        // restart the scanner and subscription if needed
        _subscription ??= cameraController.barcodes.listen(_handleBarcode);
        cameraController.start();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // stop scanner and subscription
        unawaited(_subscription?.cancel());
        _subscription = null;
        cameraController.stop();
        break;
      case AppLifecycleState.hidden:
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    // Cancel subscription and dispose controller without awaiting
    // This is safe because we've set _isDisposed = true
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(cameraController.stop());
    unawaited(cameraController.dispose());

    super.dispose();
  }
}
