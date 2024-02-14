import 'dart:developer' as d;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:geo_attendance_system/controllers/setting_controller.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';

void log(Object object) {
  if (App.instance.devMode) d.log("APP LOG $object");
}

bool isFormValid(key) {
  final form = key.currentState;
  if (form.validate()) {
    form.save();
    return true;
  }
  return false;
}

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

BoxDecoration roundedBorder({double radius}) {
  return BoxDecoration(
      border: Border.all(width: Sizes.s1),
      borderRadius: BorderRadius.circular(radius != null ? radius : Sizes.s15));
}

logErrorInFile(String message) async {
  String dir;
  Directory appDocDirectory = await getExternalStorageDirectory();
  dir = appDocDirectory.path;
  String filename = "logs_${DateFormat("ddMMyyyy").format(DateTime.now())}.txt";
  File file = File(dir + "/logs/" + filename);

  try {
    var directory = Directory(dir + "/logs");
    if (directory.existsSync()) {
      if (file.existsSync()) {
        file.writeAsString(message, mode: FileMode.append);
      } else {
        await file.create();
        file.writeAsString(message);
      }
    } else {
      await directory.create();
      if (file.existsSync()) {
        file.writeAsString(message, mode: FileMode.append);
      } else {
        await file.create();
        file.writeAsString(message);
      }
    }
  } on IOException catch (ex) {
    if (file.existsSync()) {
      file.writeAsString("Log Error=${ex.toString()}", mode: FileMode.append);
    } else {
      await file.create();
      file.writeAsString("Log Error=${ex.toString()}");
    }
  }
}

logSyncDetaInFile(String message) async {
  String dir;
  try {
    Directory appDocDirectory = await getExternalStorageDirectory();
    dir = appDocDirectory.path;
    String filename =
        "sync_${DateFormat("ddMMyyyy").format(DateTime.now())}.txt";
    File file = File(dir + "/logs/" + filename);

    var directory = Directory(dir + "/logs");
    if (directory.existsSync()) {
      if (file.existsSync()) {
        file.writeAsString(message, mode: FileMode.append);
      } else {
        await file.create();
        await file.writeAsString(message);
      }
    } else {
      await directory.create();
      if (file.existsSync()) {
        file.writeAsString(message, mode: FileMode.append);
      } else {
        await file.create();
        file.writeAsString(message);
      }
    }
  } on IOException catch (ex) {
    Common.toast("logSyncDetaInFile:Error=${ex.toString()}");
    // if (file.existsSync()) {
    //   file.writeAsString("Log Error=${ex.toString()}", mode: FileMode.append);
    // } else {
    //   await file.create();
    //   file.writeAsString("Log Error=${ex.toString()}");
    // }
  }
}

getIpAddress({SettingController settingController, bool temp}) async {
  if (settingController != null) {
    String url = settingController.getIp() == null
        ? AppUrl.urlBase() + AppUrl.subDummyPath()
        : settingController.getHttpMethod() != null
            ? settingController.getHttpMethod() +
                "://" +
                settingController.getIp() +
                AppUrl.subDummyPath(temp: temp)
            : Strings.http +
                "://" +
                settingController.getIp() +
                AppUrl.subDummyPath(temp: temp);
    return url;
  } else {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = preferences.getString(SPKeys.ipAddress.toString()) == null
        ? AppUrl.urlBase() + AppUrl.subDummyPath()
        : preferences.getString(SPKeys.httpMethod.toString()) != null
            ? preferences.getString(SPKeys.httpMethod.toString()) +
                "://" +
                preferences.getString(SPKeys.ipAddress.toString()) +
                AppUrl.subDummyPath()
            : Strings.http +
                "://" +
                preferences.getString(SPKeys.ipAddress.toString()) +
                AppUrl.subDummyPath();
    return url;
  }
}
