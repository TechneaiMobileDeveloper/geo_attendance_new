import 'package:flutter/material.dart';
import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  final bool isIcon;
  final double height;
  final bool isOutline;
  final Function onPressed;
  final double fontSize;
  final String assetName;
  final bool isAsset;
  final IconData iconData;

  const AppPrimaryButton(
      {Key key,
      @required this.text,
      this.textColor = AppColors.black,
      this.bgColor = AppColors.blue,
      this.borderColor = AppColors.blue,
      this.height,
      this.isOutline = false,
      this.onPressed,
      this.fontSize,
      this.isIcon = false,
      this.isAsset = false,
      this.iconData,
      this.assetName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(Sizes.s10)),
        ),
        height: height ?? null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: isIcon && isAsset
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.center,
          children: [
            TextButton(
              // style: ButtonStyle(
              //   // backgroundColor: MaterialStateProperty.all<Color>(
              //   //   isOutline ? Colors.transparent : bgColor,
              //   // ),
              //   // shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //   //   RoundedRectangleBorder(
              //   //     borderRadius: BorderRadius.circular(Sizes.s30),
              //   //     side: BorderSide(
              //   //       color: borderColor,
              //   //     ),
              //   //   ),
              //   // ),
              // ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Sizes.s3),
                child: Text(
                  text,
                  style:
                      TextStyle(color: isOutline ? AppColors.blue : textColor)
                          .copyWith(fontSize: fontSize ?? FontSizes.s13),
                ),
              ),
              onPressed: onPressed,
            ),
            if (isAsset)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(assetName,
                    height: Sizes.s20, width: Sizes.s20, fit: BoxFit.fill),
              ),
            if (isIcon) Icon(iconData)
          ],
        ),
      ),
    );
  }
}
