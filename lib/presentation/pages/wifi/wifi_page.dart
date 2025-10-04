import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_wifi_connect/core/utils/theme_utils.dart';
import 'package:qr_wifi_connect/core/widgets/macos_card.dart';
import 'package:qr_wifi_connect/presentation/provider/theme_provider.dart';
import 'package:qr_wifi_connect/presentation/provider/wifi_provider.dart';

class WifiPage extends ConsumerWidget {
  const WifiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = MacosTypography.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = context.isDarkModeFrom(themeMode);

    final wifiAsync = ref.watch(wifiInfoProvider);

    return TitlebarSafeArea(
      child: MacosCard(
        width: 560,
        height: 220,
        themeMode: themeMode,
        alignment: Alignment.topCenter,
        child: wifiAsync.when(
          loading: () => const Center(child: ProgressCircle()),
          error: (err, st) => Center(child: Text('Error: $err')),
          data: (wifi) {
            final ssid = wifi.ssid ?? 'Unknown';
            final bssid = wifi.bssid ?? 'Unknown';
            final ip = wifi.ip ?? 'Unknown';
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: PrettyQrView.data(
                    data: 'WIFI:T:WPA;S:$ssid;P:YOUR_PASSWORD_HERE;;',
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'SSID: ', style: typography.title1),
                            TextSpan(
                              text: ssid,
                              style: typography.title1.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('BSSID: $bssid', style: typography.subheadline),
                      const SizedBox(height: 6),
                      Text('IP: $ip', style: typography.subheadline),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}