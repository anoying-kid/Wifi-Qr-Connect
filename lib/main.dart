// lib/main.dart
import 'package:flutter/cupertino.dart';
import 'package:macos_window_utils/widgets/titlebar_safe_area.dart';
import 'package:macos_window_utils/window_manipulator.dart';
import 'package:qr/core/constants/route_constants.dart';
import 'package:qr/presentation/router/route_generator.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManipulator.initialize();
  WindowManipulator.hideTitle();
  WindowManipulator.makeTitlebarTransparent();
  WindowManipulator.enableFullSizeContentView();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      // title: 'QR App',
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        // Theme customization here
      ),
      initialRoute: RouteConstants.home,
      onGenerateRoute: RouteGenerator.generateRoute,
      // Optional: Handle unknown routes
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
