import 'dart:developer';
import 'dart:io';

import 'package:geo_attendance_system/utils/common.dart';

class FileCheck {
  static Future<File> fileSizeCheck(File f, int maxSize) async {
    try {
      int sizeInBytes = f.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > maxSize) {
        if (maxSize == 10) {
          Common.toast("Strings.imageFileSizeExceeds");
        } else {
          Common.toast("Strings.videoFileSizeExceeds");
        }
      } else {
        return f;
      }
    } catch (e) {
      log("File is not selected");
    }
    return null;
  }

  static List<String> imageExtensionList() {
    return [".jpg", ".jpeg", ".png"];
  }
}
