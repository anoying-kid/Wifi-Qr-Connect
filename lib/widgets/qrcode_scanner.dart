import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

enum QrDetail { wifi, link, text }

class BarcodeScanner extends StatefulWidget {
  static const routeName = '/scanner';
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  Map<String, String> getWifiDetails(String code) {
    String ssid = code.substring(code.indexOf('S:') + 2, code.indexOf(';T'));
    String password =
        code.substring(code.indexOf('P:') + 2, code.indexOf(';H'));
    return {'ssid': ssid, 'password': password};
  }

  void connectToWifi(String ssid, String password) async {
    await Process.run(
      'networksetup',
      ['-setairportpower', 'en0', 'on'],
    );
    await Process.run(
        'networksetup', ['-setairportnetwork', 'en0', ssid, password]);
  }

  void browserSearch(String code) async {
    await Process.run('open', [code]);
  }

  void qrCodeRunner(
    QrDetail qrState,
    String code,
  ) {
    switch (qrState) {
      case QrDetail.link:
        browserSearch(code);
        break;
      case QrDetail.wifi:
        Map<String, String> wifiDetails = getWifiDetails(code);
        connectToWifi(wifiDetails['ssid']!, wifiDetails['password']!);
        break;
      case QrDetail.text:
        browserSearch("https://google.com/search?q=$code");
    }
  }

  void qrChecker(String code, BuildContext context) async {
    String windowTitile = code;
    late String pBTitle;
    late QrDetail qrState;
    await FlutterPlatformAlert.playAlertSound();

    if (code.substring(0, 7) == 'WIFI:S:') {
      qrState = QrDetail.wifi;
      Map<String, String> wifiDetails = getWifiDetails(code);
      windowTitile = "${wifiDetails['ssid']} ${wifiDetails['password']}";
      pBTitle = 'Connect';
    } else if (code.substring(0, 4) == 'http') {
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
      negativeButtonTitle: "cancel",
    );

    switch (clickedButton) {
      case CustomButton.positiveButton:
        qrCodeRunner(qrState, code);
        if (context.mounted) Navigator.of(context).pop();
        break;
      case CustomButton.negativeButton:
        cameraController.start();
        break;
      case CustomButton.neutralButton:
        cameraController.start();
        break;
      case CustomButton.other:
        cameraController.start();
        break;
    }
  }

  MobileScannerController cameraController =
      MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              qrChecker(barcode.rawValue!, context);
              cameraController.stop();
            }
          }
        },
      ),
    );
  }
}
