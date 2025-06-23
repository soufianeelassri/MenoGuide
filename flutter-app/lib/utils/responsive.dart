import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double scale(BuildContext context, double mobile,
      {double? tablet, double? desktop}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024 && desktop != null) return desktop;
    if (width >= 600 && tablet != null) return tablet;
    return mobile;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    if (isDesktop(context))
      return const EdgeInsets.symmetric(horizontal: 120, vertical: 32);
    if (isTablet(context))
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }
}
