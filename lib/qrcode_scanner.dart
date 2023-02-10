import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  static const routeName = '/scanner';
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  void connectToWifi(String code) async {
    String ssid = code.substring(code.indexOf('S:') + 2, code.indexOf(';T'));
    String password =
        code.substring(code.indexOf('P:') + 2, code.indexOf(';H'));
    await Process.run(
      'networksetup',
      ['-setairportpower', 'en0', 'on'],
    );
    await Process.run(
        'networksetup', ['-setairportnetwork', 'en0', ssid, password]);
  }

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
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                connectToWifi(barcode.rawValue!);
                Navigator.of(context).pop();
              }
            }
          },
        ));
  }
}
