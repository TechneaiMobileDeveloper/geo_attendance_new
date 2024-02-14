import 'package:flutter/foundation.dart';
import 'package:geo_attendance_system/models/attendance_data.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/utils/methods.dart';
import 'package:get/get.dart';

import '../controllers/setting_controller.dart';

class ApiService extends GetConnect {
  AttendanceData data;
  final settingController = Get.find<SettingController>();

  getAttendanceData(Map<String, dynamic> body) async {
    try {
      bool isInternet = await hasNetwork();
      String url = AppUrl.urlFaceBase() + AppUrl.getAttendance;
      Map<String, String> headers = {
        'content-type': 'multipart/form-data',
      };
      if (isInternet) {
        Response response =
            await post(url, body, contentType: 'multipart/form-data');
        data = AttendanceData.fromJson(response.body);
        return data;
      } else {
        return null;
      }
    } catch (ex) {
      print(ex.toString());
    }
  }

  getReportData(String fDate, String tDate, {int isAcceptance = 1}) async {
    try {
      bool isInternet = await hasNetwork();
      String url = await getIpAddress(settingController: settingController);
      url = url + AppUrl.getReportAttendance;
      Map<String, dynamic> body = {};
      body['first_date'] = fDate;
      body['last_date'] = tDate;
      body['acceptance'] = isAcceptance;
      if (isInternet) {
        Response response = await post(url, body);
      }
    } on Exception catch (ex) {
      if (kDebugMode) {
        print("ApiService::getReportData=${ex.toString()}");
      }
    }
  }
}
