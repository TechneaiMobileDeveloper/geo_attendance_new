import 'package:flutter/material.dart';
import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:geo_attendance_system/utils/text_styles.dart';
import 'package:geo_attendance_system/utils/ui_helper.dart';
import 'package:get/get.dart';

class CustomAppBar extends PreferredSize {
  final double height;
  final Color color;
  final TextStyle textStyle;
  final String title;
  final bool isBack;
  final actionWidget;
  final Function onTapHamburger;
  final bool isHamburger;

  CustomAppBar({
    this.color = AppColors.greyText,
    this.height = kToolbarHeight,
    this.textStyle,
    this.title,
    this.isBack = false,
    this.actionWidget,
    this.onTapHamburger,
    this.isHamburger = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Sizes.s5),
      height: preferredSize.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        border: Border(
          bottom: BorderSide(color: AppColors.black, width: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isBack)
                GestureDetector(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back, size: Sizes.s24),
                    )),
              C2(),
              Text(
                title ?? "",
                style: textStyle ??
                    TextStyles.defaultRegular.copyWith(
                        fontFamily: FontFamily.medium, fontSize: FontSizes.s13),
              ),
            ],
          ),
          Row(
            children: [
              actionWidget ?? C0(),
              if (isHamburger)
                GestureDetector(
                    onTap: () => onTapHamburger(),
                    child:
                        Icon(Icons.menu, size: Sizes.s24, color: Colors.white))
            ],
          )
        ],
      ),
    );
  }
}
