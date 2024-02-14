

import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:geo_attendance_system/controllers/report_controller.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/service/LocalNotificationService.dart';
import 'package:get/get.dart';

main()
{

  test("calendar_report", () async{
    //  Get.put(LocalNotificationService());
      ReportController reportController = Get.put(ReportController(false));
      String url = AppUrl.urlBase()+AppUrl.subPath();
      log("apiUrl=$url");
      await reportController.viewCalenderReport("12", "2023-03-05",url: url);
  });
}