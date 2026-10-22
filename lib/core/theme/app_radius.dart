import 'package:flutter/material.dart';

/// Standardized Corner Radii Tokens
class AppRadius {
  static const double xsVal = 4.0;
  static const double smVal = 8.0;
  static const double mdVal = 12.0;
  static const double lgVal = 16.0;
  static const double xlVal = 24.0;
  static const double fullVal = 999.0;

  static const BorderRadius xs = BorderRadius.all(Radius.circular(xsVal));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(smVal));
  static const BorderRadius md = BorderRadius.all(Radius.circular(mdVal));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(lgVal));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(xlVal));
  static const BorderRadius full = BorderRadius.all(Radius.circular(fullVal));
}
