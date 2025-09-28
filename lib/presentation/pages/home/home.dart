import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'widgets/qrcode_scanner.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            Expanded(
                flex: 1,
                child: Container(height: double.infinity, child: SideBar())),
            Expanded(
                flex: 2,
                child: Container(height: double.infinity, child: SideBar())),
          ],
        ));
  }
}

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Text("QR Scanner"),
    );
  }
}
