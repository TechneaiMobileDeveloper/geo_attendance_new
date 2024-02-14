import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/utils/sizes.dart';

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(Sizes.s7))),
        width: Sizes.s40,
        height: Sizes.s40,
        child: SpinKitCircle(
          color: AppColors.blue,
          size: Sizes.s30,
        ),
      ),
    );
  }
}
