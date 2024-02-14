import 'package:flutter/material.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:geo_attendance_system/utils/text_styles.dart';

import 'app_colors.dart';

ThemeData appTheme = ThemeData(
  iconTheme: IconThemeData(size: Sizes.s20, color: Colors.black),
  brightness: Brightness.light,
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.black87),
          textStyle:
              MaterialStateProperty.all(TextStyle(color: Colors.black)))),
  primaryColor: AppColors.greyText,
  primaryColorLight: AppColors.greyTextMedium,
  primaryColorDark: AppColors.primary,
  scaffoldBackgroundColor: Colors.white,
  bottomAppBarColor: AppColors.primaryLightColor,
  cardColor: Colors.white,
  dividerColor: Colors.black,
  splashFactory: InkSplash.splashFactory,
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  fontFamily: FontFamily.regular, colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.fontGray,
      onPrimary: AppColors.white, //button text
      secondary: AppColors.white,
      onSecondary: AppColors.greyLight,
      onError: AppColors.red,
      error: AppColors.red,
      background: AppColors.white,
      onBackground: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.black)
    .copyWith(secondary: AppColors.primaryLightColor),
);
