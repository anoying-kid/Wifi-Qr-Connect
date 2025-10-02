import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:qr/presentation/pages/home/widgets/qrcode_scanner.dart'; // Import the package

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
                  leading: MacosIcon(Icons.wifi), label: Text('QR Scanner')),
              SidebarItem(label: Text('QR Scanner')),
            ],
          );
        },
        minWidth: 200,
        bottom: const MacosListTile(
            leading: MacosIcon(CupertinoIcons.profile_circled),
            title: Text('Login'),
            subtitle: Text('login@apple.com'),
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
            return const Text("QR Scanner"); // Your content
          },
        ),
      ][pageIndex],
    );
  }
}
