import 'package:flutter/material.dart';
import 'package:qr/screen/qr_screen.dart';
import 'package:qr/widgets/qrcode_scanner.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const QrScreen(),
        routes: {
          BarcodeScanner.routeName :(context) => const BarcodeScanner(),
        },
    );
  }
}