import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_wifi_connect/presentation/provider/theme_provider.dart';

class WifiPage extends ConsumerWidget {
  const WifiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return PrettyQrView.data(
      data: 'lorem ipsum dolor sit amet',
      decoration: PrettyQrDecoration(
        quietZone: PrettyQrQuietZone.standart,
        shape: PrettyQrShape.custom(
          PrettyQrSmoothSymbol(
            color: themeMode == ThemeMode.dark ? MacosColors.white : MacosColors.black,
          ),
        ),
      ),
    );
  }
}