import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geo_attendance_system/controllers/report_controller.dart';
import 'package:geo_attendance_system/network/api_client.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:get/get.dart';
import '../controllers/setting_controller.dart';
import 'package:geo_attendance_system/models/attendances_report/attendances_report_model.dart' as r;
import '../models/calender_report/calender_report_model.dart';
import '../utils/methods.dart';

class AttendanceReportRepository {

  final APIClient _apiClient = APIClient();
  ReportController reportController;

  final empAttendancesReportData = r.AttendanceReportModel().obs;




  void getLocationMasterDetails() {
    try{
      String url = AppUrl.urlBase() + AppUrl.getAllEmployeeAttendancesReport;
      print("Location url :: $url");
      //_apiClient.get(url,queryParameters: {}).then((value){
      _apiClient.post(url,data: {"type" : "LOCATION"},
          queryParameters: {}
      ).then((value){
        reportController.onResponseGetLocationDetails(value);
      });
    }
    on DioError catch(ex){

      if(kDebugMode){
        print(ex.toString());
      }
    } catch(ex){
      if(kDebugMode){
        print(ex.toString());
      }
    }
  }





}
