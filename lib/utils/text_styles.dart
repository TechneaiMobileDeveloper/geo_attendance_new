import 'package:flutter/material.dart';
import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/utils/sizes.dart';

class FontFamily {
  static const String regular = "Poppins-Regular";
  static const String bold = "Poppins-Bold";
  static const String extraBold = "Poppins-ExtraBold";
  static const String extraLight = "Poppins-ExtraLight";
  static const String light = "Poppins-Light";
  static const String medium = "Poppins-Medium";
  static const String semiBold = "Poppins-SemiBold";
  static const String thin = "Poppins-Thin";
}

class TextStyles {
  static const TextDecoration underline = TextDecoration.underline;
  static const TextDecoration lineThrough = TextDecoration.lineThrough;

  static TextStyle get appBarTittle => TextStyle(
        fontFamily: FontFamily.semiBold,
        fontSize: FontSizes.s16,
        color: Colors.black,
        inherit: false,
      );

  static TextStyle get title => TextStyle(
        fontFamily: FontFamily.bold,
        fontSize: FontSizes.s20,
        color: Colors.black,
        inherit: false,
      );

  static TextStyle get dialog => TextStyle(
        fontFamily: FontFamily.bold,
        fontSize: FontSizes.s15,
        color: Colors.black,
        inherit: false,
      );

  static TextStyle get timer => TextStyle(
        fontFamily: FontFamily.bold,
        fontSize: FontSizes.s20,
        color: Colors.black,
        inherit: false,
      );

  static TextStyle get greyText => TextStyle(
        fontSize: FontSizes.s13,
        color: AppColors.greyText,
        inherit: false,
      );

  static TextStyle get bigTitle => TextStyle(
        fontSize: FontSizes.s18,
        color: AppColors.black,
        inherit: false,
      );

  static TextStyle get appBarBold => TextStyle(
        fontSize: FontSizes.s20,
        color: Colors.black,
        fontWeight: FontWeight.bold,
        inherit: false,
      );

  static TextStyle get url => TextStyle(
        fontSize: FontSizes.s13,
        color: Colors.blue,
        inherit: false,
        decoration: TextStyles.underline,
      );

  static TextStyle get defaultRegular => TextStyle(
        fontSize: FontSizes.s15,
        color: Colors.black,
        fontFamily: FontFamily.regular,
        inherit: true,
      );

  static TextStyle get greyDefaultRegular => TextStyle(
        fontSize: FontSizes.s13,
        color: Colors.grey,
        fontFamily: FontFamily.regular,
        inherit: false,
      );

  static TextStyle get defaultRegularBold => TextStyle(
        fontSize: FontSizes.s13,
        color: Colors.black,
        fontFamily: FontFamily.regular,
        fontWeight: FontWeight.bold,
        inherit: false,
      );

  static TextStyle get textStyle => TextStyle(
      fontSize: FontSizes.s15,
      color: Colors.black,
      fontFamily: FontFamily.regular);

  static TextStyle get hintStyle => TextStyle(
      fontSize: FontSizes.s13,
      fontWeight: FontWeight.normal,
      fontFamily: FontFamily.regular);

  static TextStyle get labelStyle => TextStyle(
      fontSize: FontSizes.s13,
      fontWeight: FontWeight.normal,
      color: AppColors.fontGray,
      fontFamily: FontFamily.semiBold);
}
