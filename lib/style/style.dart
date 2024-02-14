import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:get/get.dart';

boxDecoration(
    {Color bgColor,
    double radius,
    bool isSymetric,
    Color borderColor,
    double width}) {
  return BoxDecoration(
      color: bgColor != null ? bgColor : AppColors.primary,
      border: Border.all(
          color: borderColor != null ? borderColor : AppColors.black,
          width: width != null ? width : Get.width),
      borderRadius: BorderRadius.all(
          Radius.circular(radius != null ? radius : Sizes.s15)));
}

buttonStyle() {
  return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(AppColors.primary));
}
