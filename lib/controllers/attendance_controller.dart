import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geo_attendance_system/network/api_client.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/repository/attendance_report_repository.dart';
import 'package:geo_attendance_system/utils/methods.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  APIClient apiClient = APIClient();
  AttendanceReportRepository repository;

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<dynamic> saveAttendanceOnServer(Map<String, dynamic> body) async {
    try {
      String url =
          await getIpAddress(temp: true) + AppUrl.saveAttendance; // todo
     print("save data :$url");
     print("save data :${json.encode(body)}");
     dynamic response =  await apiClient.post(url, mapData: body);
      print("response :${json.encode(response)}");
     return response;
    } catch (ex) {
      print(ex.toString());
    }
  }
    @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }



}
