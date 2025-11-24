import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class ResponsiveInfo {
  final double screenWidth;
  final double screenHeight;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  ResponsiveInfo({
    required this.screenWidth,
    required this.screenHeight,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  double width(double value) => value * (screenWidth / 375);

  double height(double value) => value * (screenHeight / 812);

  double text(double fontSize) {
    if (isDesktop) return fontSize * 1.3;
    if (isTablet) return fontSize * 1.1;
    return fontSize;
  }

  int getCrossAxisCount(double width) {
    if (width > 1400) return 3;
    if (width > 1100) return 3;
    if (width > 800) return 2;
    return 1;
  }

  double getAspectRatio(double width) {
    if (width > 1400) return 1.3;
    if (width > 1100) return 1.2;
    return 1.1;
  }
}

class ResponsiveNotifier extends StateNotifier<ResponsiveInfo> {
  ResponsiveNotifier()
      : super(
          ResponsiveInfo(
            screenWidth: 375,
            screenHeight: 812,
            isMobile: true,
            isTablet: false,
            isDesktop: false,
          ),
        );

  void updateFromContext(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;
    final isDesktop = width >= 1100;

    state = ResponsiveInfo(
      screenWidth: width,
      screenHeight: size.height,
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
    );
  }
}

final responsiveProvider =
    StateNotifierProvider<ResponsiveNotifier, ResponsiveInfo>(
  (ref) => ResponsiveNotifier(),
);
