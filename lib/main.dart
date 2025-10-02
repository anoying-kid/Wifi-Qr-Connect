// lib/main.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:qr_wifi_connect/core/constants/route_constants.dart';
import 'package:qr_wifi_connect/presentation/provider/theme_provider.dart';
import 'package:qr_wifi_connect/presentation/router/route_generator.dart';

/// This method initializes macos_window_utils and styles the window.
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

Future<void> main(List<String> args) async {
  await _configureMacosWindowUtils();
  WidgetsFlutterBinding.ensureInitialized();
  WindowManipulator.hideTitle();
  WindowManipulator.makeTitlebarTransparent();
  WindowManipulator.enableFullSizeContentView();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MacosApp(
      title: 'QR App',
      themeMode: themeMode, // Use the theme from provider
      initialRoute: RouteConstants.home,
      onGenerateRoute: RouteGenerator.generateRoute,
      onUnknownRoute: (settings) => CupertinoPageRoute(
        builder: (_) => const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Page Not Found'),
          ),
          child: Center(
            child: Text('The requested page was not found.'),
          ),
        ),
      ),
    );
  }
}