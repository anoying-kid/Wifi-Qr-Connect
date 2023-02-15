import 'package:flutter/material.dart';
import '../widgets/qrcode_scanner.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepPurpleAccent,
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.5,
            child: OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(BarcodeScanner.routeName),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 2)),
              child: const FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  'Start',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 200,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ));
  }
}
