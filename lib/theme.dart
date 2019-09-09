import 'package:flutter/material.dart';

final ThemeData SpenslyTheme = ThemeData(
  accentColor: SpenslyColors.green,
  accentColorBrightness: Brightness.light,
  brightness: Brightness.light,
  primaryColor: SpenslyColors.green,
  primaryColorBrightness: Brightness.light
);

class SpenslyColors {
  SpenslyColors._();

  static const MaterialColor green = const MaterialColor(0xFFEAF2EF, {});
}