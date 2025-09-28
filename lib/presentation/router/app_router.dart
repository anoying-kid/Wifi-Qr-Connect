import 'package:flutter/cupertino.dart';
import 'package:qr/core/constants/route_constants.dart';
import 'package:qr/presentation/pages/home/home.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.home:
        return CupertinoPageRoute(builder: (_) => const Home());
      default:
        return CupertinoPageRoute(
          builder: (_) => CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('Page Not Found'),
            ),
            child: Center(
              child: Text('Page ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}
