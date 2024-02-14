import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/utils/text_styles.dart';
import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWight;
  final TextAlign textAlign;
  final String fontFamily;
  final bool isUnderline;
  final Color color;

  const CustomText(
      {Key key,
      this.text,
      this.fontSize = 23.4,
      this.color = AppColors.black,
      this.isUnderline = false,
      this.textAlign = TextAlign.start,
      this.fontFamily = FontFamily.regular,
      this.fontWight = FontWeight.normal, textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyles.defaultRegular
          .copyWith(fontFamily: fontFamily, color: color, fontWeight: fontWight)
          .copyWith(
              fontSize:
                  fontSize ?? 23.4 - MediaQuery.of(context).devicePixelRatio,
              decoration:
                  isUnderline ? TextDecoration.underline : TextDecoration.none),
    );
  }

  getTitleText(String text, BuildContext context,
      {double fontSize, Color color, bool isUnderline = false}) {
    return Text(
      text,
      style: TextStyles.defaultRegular
          .copyWith(
              fontFamily: 'Montserrat',
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.bold)
          .copyWith(
              fontSize:
                  fontSize ?? 23.4 - MediaQuery.of(context).devicePixelRatio,
              decoration:
                  isUnderline ? TextDecoration.underline : TextDecoration.none),
    );
  }
}
