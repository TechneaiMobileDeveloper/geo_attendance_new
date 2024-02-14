import 'package:flutter/material.dart';
import 'package:geo_attendance_system/utils/assets.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:geo_attendance_system/utils/ui_helper.dart';

class BottomSheetDialog extends StatelessWidget {
  final Widget child;

  BottomSheetDialog({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Sizes.s350,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Sizes.s30),
                topRight: Radius.circular(Sizes.s30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            C16(),
            Container(
              width: Sizes.s120,
              height: Sizes.s5,
              child: Image.asset(Assets.techAi),
            ),
            Expanded(child: child),
          ],
        ));
  }
}
