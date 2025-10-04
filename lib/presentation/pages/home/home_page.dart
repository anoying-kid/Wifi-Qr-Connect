import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:qr_wifi_connect/presentation/pages/home/widgets/qrcode_scanner.dart';
import 'package:qr_wifi_connect/presentation/pages/wifi/wifi_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Use MacosWindow and MacosScaffold for a native macOS structure
    return MacosWindow(
      sidebar: Sidebar(
        dragClosed: false,
        builder: (context, scrollController) {
          // Build your sidebar items here
          return SidebarItems(
            currentIndex: pageIndex, // Manage state as needed
            scrollController: scrollController,
            itemSize: SidebarItemSize.large,
            onChanged: (newIndex) {
              setState(() {
                pageIndex = newIndex;
              });
            },
            items: const [
              SidebarItem(
                  leading: MacosIcon(Icons.linked_camera), label: Text('QR Scanner')),
              SidebarItem(
                  leading: MacosIcon(Icons.wifi), label: Text('WiFi')),
            ],
          );
        },
        minWidth: 200,
        bottom: const MacosListTile(
            leading: MacosIcon(CupertinoIcons.profile_circled),
            title: Text('QR WiFi'),
            subtitle: Text('Version 2.0.0'),
          ),
      ),
      child: [
        ContentArea(
          builder: (context, scrollController) {
            return BarcodeScanner(); // Your content
          },
        ),
        ContentArea(
          builder: (context, scrollController) {
            return WifiPage(); // Your content
          },
        ),
      ][pageIndex],
    );
  }
}
