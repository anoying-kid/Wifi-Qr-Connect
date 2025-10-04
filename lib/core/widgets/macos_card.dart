import 'package:flutter/material.dart';
import 'package:qr_wifi_connect/core/utils/utils.dart';

class MacosCard extends StatelessWidget {
  const MacosCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.themeMode,
    this.color,
    this.padding = const EdgeInsets.all(12.0),
    this.alignment = Alignment.topCenter,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.elevation = 6.0,
  });

  final Widget child;
  final double? width;
  final double? height;
  final ThemeMode? themeMode;
  final Color? color;
  final EdgeInsets padding;
  final Alignment alignment;
  final BorderRadius borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkModeFrom(themeMode);
    final effectiveColor = color ??
        (isDark ? const Color.fromARGB(255, 47, 47, 47) : const Color.fromARGB(255, 238, 238, 238));

    return Align(
      alignment: alignment,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}
