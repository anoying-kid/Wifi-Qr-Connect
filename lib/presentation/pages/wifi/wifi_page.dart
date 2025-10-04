import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_wifi_connect/core/utils/theme_utils.dart';
import 'package:qr_wifi_connect/core/widgets/macos_card.dart';
import 'package:qr_wifi_connect/presentation/provider/theme_provider.dart';

class WifiPage extends ConsumerWidget {
  const WifiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = MacosTypography.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = context.isDarkModeFrom(themeMode);

    // Put the card at the top by using Alignment.topCenter in the MacosCard.
    return TitlebarSafeArea(
      child: MacosCard(
        width: 560,
        height: 220,
        themeMode: themeMode,
        alignment: Alignment.topCenter,
        // default macOS-like background color is already used by MacosCard
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // left: fixed-size QR block
            SizedBox(
              height: 200,
              width: 200,
              child: PrettyQrView.data(
                data: 'WIFI:T:WPA;S:Room no 306_5g;P:password_here;;',
                decoration: PrettyQrDecoration(
                  quietZone: PrettyQrQuietZone.standart,
                  shape: PrettyQrShape.custom(
                    PrettyQrSmoothSymbol(
                      color: isDark ? MacosColors.white : MacosColors.black,
                    ),
                  ),
                ),
              ),
            ),
      
            const SizedBox(width: 20),
      
            // right: information column
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'SSID: ',
                          style: typography.title1,
                        ),
                        TextSpan(
                          text: 'Room_no_306_5g', // Replace with your variable
                          style: typography.title1.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Password: ',
                          style: typography.title1,
                        ),
                        TextSpan(
                          text: '••••••••', // Replace with your variable
                          style: typography.title1.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Security: ',
                          style: typography.title1,
                        ),
                        TextSpan(
                          text: 'WPA2', // Replace with your variable
                          style: typography.title1.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}