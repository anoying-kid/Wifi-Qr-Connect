import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

enum QrDetail { wifi, link, text }

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner>
    with WidgetsBindingObserver {
  // controller is created with autoStart: false so we manage lifecycle manually
  final MobileScannerController cameraController = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  StreamSubscription<BarcodeCapture>? _subscription;
  bool _isCameraLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // observe app lifecycle to pause/resume the camera
    WidgetsBinding.instance.addObserver(this);

    // listen to the barcode events
    _subscription = cameraController.barcodes.listen(_handleBarcode);

    // wait for the first frame so the MobileScanner widget can attach the controller
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
      debugPrint('MobileScannerException while starting: ${e.errorCode} ${e.toString()}');
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

  void connectToWifi(String ssid, String password) async {
    await Process.run('networksetup', ['-setairportpower', 'en0', 'on']);
    await Process.run('networksetup', ['-setairportnetwork', 'en0', ssid, password]);
  }

  void browserSearch(String code) async {
    await Process.run('open', [code]);
  }

  void qrCodeRunner(QrDetail qrState, String code) {
    switch (qrState) {
      case QrDetail.link:
        browserSearch(code);
        break;
      case QrDetail.wifi:
        final wifiDetails = getWifiDetails(code);
        connectToWifi(wifiDetails['ssid']!, wifiDetails['password']!);
        break;
      case QrDetail.text:
        browserSearch("https://google.com/search?q=$code");
        break;
    }
  }

  void qrChecker(String code, BuildContext context) async {
    if (_isDisposed || !mounted) return;
    
    String windowTitile = code;
    late String pBTitle;
    late QrDetail qrState;
    await FlutterPlatformAlert.playAlertSound();

    if (code.startsWith('WIFI:S:')) {
      qrState = QrDetail.wifi;
      final wifiDetails = getWifiDetails(code);
      windowTitile = "${wifiDetails['ssid']} ${wifiDetails['password']}";
      pBTitle = 'Connect';
    } else if (code.startsWith('http')) {
      qrState = QrDetail.link;
      pBTitle = 'Open';
    } else {
      qrState = QrDetail.text;
      pBTitle = "Google";
    }

    final clickedButton = await FlutterPlatformAlert.showCustomAlert(
      windowTitle: windowTitile,
      text: '',
      positiveButtonTitle: pBTitle,
      negativeButtonTitle: "Cancel",
    );

    if (_isDisposed || !mounted) return;

    switch (clickedButton) {
      case CustomButton.positiveButton:
        qrCodeRunner(qrState, code);
        if (context.mounted) Navigator.of(context).pop();
        break;
      default:
        // resume scanning
        if (!_isDisposed) {
          cameraController.start();
        }
        break;
    }
  }

  // --- app lifecycle handling ---
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

  // --- UI (MobileScanner kept in the tree always) ---
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
              // Keep the scanner always in the widget tree so the controller can attach.
              MobileScanner(
                controller: cameraController,
                // we handle barcode stream separately via controller.barcodes subscription
                onDetect: (_) {},
              ),

              // simple loading overlay while camera starts
              if (_isCameraLoading)
                Container(
                  color: Colors.white,
                  child: const Center(child: ProgressCircle()),
                )
            ],
          );
        }),
      ],
    );
  }
}

// Helper function to ignore futures in fire-and-forget scenarios
void unawaited(Future<void>? future) {
  // Explicitly ignore the future
}