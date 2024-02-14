import 'package:flutter/material.dart';
import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/utils/assets.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:geo_attendance_system/utils/text_styles.dart';
import 'package:geo_attendance_system/utils/ui_helper.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String) onTextChanged;
  final TextEditingController controller;

  CustomSearchBar({Key key, this.hintText, this.onTextChanged, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Sizes.s10, vertical: Sizes.s3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            color: AppColors.greyLight, // set border color
            width: 1.0), // set border width
        borderRadius: BorderRadius.all(
            Radius.circular(Sizes.s12)), // set rounded corner radius
      ),
      child: Row(
        children: [
          Image.asset(
            Assets.techAi,
            height: Sizes.s20,
            width: Sizes.s20,
          ),
          C7(),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyles.hintStyle,
                labelStyle: TextStyles.defaultRegular,
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (onTextChanged != null) onTextChanged(value);
              },
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
