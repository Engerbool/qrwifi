import 'package:flutter/material.dart';

/// Responsive layout utilities for web/desktop support
class Responsive {
  Responsive._();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Check if current screen is tablet or larger
  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint;

  /// Get maximum content width based on screen size
  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return 1000;
    if (width >= tabletBreakpoint) return 800;
    return double.infinity;
  }

  /// Get dynamic grid cross axis count based on screen width
  static int gridCrossAxisCount(BuildContext context, {int mobileCount = 4}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return mobileCount + 4; // 8 for desktop
    if (width >= tabletBreakpoint) return mobileCount + 2; // 6 for tablet
    return mobileCount; // 4 for mobile
  }

  /// Get screen-appropriate padding
  static EdgeInsets screenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    return const EdgeInsets.all(24);
  }

  /// Get horizontal padding only
  static EdgeInsets horizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
    return const EdgeInsets.symmetric(horizontal: 24);
  }

  /// Get spacing multiplier based on screen size
  static double spacingMultiplier(BuildContext context) {
    if (isDesktop(context)) return 1.5;
    if (isTablet(context)) return 1.25;
    return 1.0;
  }

  /// Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// Get preview max width for poster preview
  static double previewMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return 500;
    if (width >= tabletBreakpoint) return 450;
    return 400;
  }

  /// Get character image size based on screen
  static double characterImageSize(BuildContext context) {
    if (isDesktop(context)) return 160;
    if (isTablet(context)) return 140;
    return 120;
  }
}

/// A widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (Responsive.isDesktop(context) && desktop != null) {
          return desktop!(context, constraints);
        }
        if (Responsive.isTablet(context) && tablet != null) {
          return tablet!(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }
}

/// A widget that centers content with a max width on larger screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.contentMaxWidth(context),
        ),
        padding: padding ?? Responsive.horizontalPadding(context),
        child: child,
      ),
    );
  }
}
