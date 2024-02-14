import 'package:flutter/material.dart';
import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:geo_attendance_system/utils/widget/app_text_field.dart';

import '../../utils/text_styles.dart';

class CustomDateWidget extends StatelessWidget {
  final TextEditingController datePickerController;
  final double width;
  final double height;
  final DateTime initialDate;
  final TextStyle customTextStyle;

  const CustomDateWidget(
      {Key key,
      this.datePickerController,
      this.width = 180,
      this.height = 50,
      this.initialDate,
      this.customTextStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: Sizes.s35, minWidth: Sizes.s30),
      child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(FontSizes.s10),
          decoration: BoxDecoration(
              color: AppColors.greyLightBackground,
              borderRadius: BorderRadius.circular(Sizes.s8)),
          child:
              // Obx((){
              //   return
              Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: AppTextField(
                  isBoarder: false,
                  enabled: false,
                  textAlign: TextAlign.center,
                  controller: datePickerController,
                  contentPadding: EdgeInsets.symmetric(vertical: Sizes.s15),
                ),
              ),
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: AppColors.black,
                  size: Sizes.s24,
                ),
              )
            ],
          )
          // })

          ),
    );
  }
}
