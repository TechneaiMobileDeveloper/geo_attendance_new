import 'package:flutter/material.dart';
import 'package:geo_attendance_system/ui/widgets/custom_text_widget.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:get/get.dart';

import '../../res/strings.dart';

class ConfirmDialog extends StatelessWidget {
  final Function onYes, onNo;
  final String message;

  ConfirmDialog({Key key, this.onYes, this.onNo, this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: Get.height * 0.1,
        child: Center(
          child: CustomText(
            text: message,
            fontSize: FontSizes.s16,
            fontWight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: onYes,
          child: Text(Strings.yes),
        ),
        ElevatedButton(
          onPressed: onNo,
          child: Text(Strings.no),
        ),
      ],
    );
  }
}
