import 'package:flutter/cupertino.dart';
import 'app_router.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return AppRouter.generateRoute(settings);
  }
}