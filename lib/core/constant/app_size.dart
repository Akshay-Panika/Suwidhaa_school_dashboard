import 'package:flutter/material.dart';

extension AppSize on BuildContext {
  double get sWidth => MediaQuery.of(this).size.width;
  double get sHeight => MediaQuery.of(this).size.height;

  // Responsive Text Sizes (based on width)
  double get text10 => (sWidth * 0.025).clamp(10, 12);
  double get text12 => (sWidth * 0.03).clamp(12, 14);
  double get text14 => (sWidth * 0.035).clamp(14, 16);
  double get text16 => (sWidth * 0.04).clamp(16, 18);
  double get text18 => (sWidth * 0.045).clamp(18, 20);
  double get text20 => (sWidth * 0.05).clamp(20, 22);
  double get text22 => (sWidth * 0.055).clamp(22, 24);
  double get text24 => (sWidth * 0.06).clamp(24, 26);
  double get text26 => (sWidth * 0.065).clamp(26, 30);
}