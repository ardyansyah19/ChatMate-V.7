import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.darkGreen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.tealGreen,
      brightness: Brightness.light,
      primary: AppColors.darkGreen,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightAppBar,
      foregroundColor: Colors.black87,
      elevation: 0.5,
      centerTitle: false,
    ),
    dividerColor: AppColors.lightDivider,
    useMaterial3: true,
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.tealGreen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.tealGreen,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkAppBar,
      foregroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: false,
    ),
    dividerColor: AppColors.darkDivider,
    useMaterial3: true,
  );
}
