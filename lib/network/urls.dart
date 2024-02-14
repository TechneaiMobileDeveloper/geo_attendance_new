import 'package:flutter/foundation.dart';

class AppUrl {
  static String urlBase({bool temp}) {
    return urlConnectUsDummy();
    //return kDebugMode ? urlConnectUsDummy() : "http://13.126.136.155";
  }

  static String urlFaceBase() {
    return "http://test.csjewellers.com:81/cspl/";
  }

  static String uploadPath() {
    return "http://114.29.232.154/connectus/";
  }

  static String urlConnectUsDummy() {
    return "http://13.126.136.155";
  }

  static String subPath() {
    return '/techneai-dummy/api/v1/';
  }
  static String connectUsSubPath(){
    return "/connectus/api/v1/";
  }

  static String subDummyPath({bool temp = false}) {
    return subPath();
  }
  static String get getFaceData => "emb.json";
  // todo
  //static String get getFaceData => kDebugMode ? "emb.json" : "emb_new.json";

  // static String get getFaceData => kDebugMode ? "emb_new.json" : "emb_new.json";

  static String get oldFaceData => "emb.json";

  //static String get addFaceDataOld => "AddUserFace.php";

  //static String get addFaceData => "AddUserFace.php";
 // static String get addFaceData => kDebugMode ? "AddUserFace.php" : "AddUserFaceNew.php";
  static String get addFaceData => "AddUserFace.php";


  // static String get addFaceData => "AddUserFaceNew.php";

  static String get empId => "getEmpId";

  static String get uploadImage => "uploadImg";

  // static String get saveAttendance => "attendanceApi";
  static String get saveAttendance => "insertAttendanceData";

  static String get saveLocation => "saveLocation.php";

  static String get getAttendance => "getTotalInOut";

  static String get getReportAttendance => "getAttendanceData";

  static String get validateEmployee => "validationEmp";

  static String get todayApprovalReport => "todayApprovalReport";

  static String get todayApprovalManualReport => "todayMannualReport";

  //static String get todayApprovalReport => "todayApprovalReport";

  static String get getTotalInOutData => "getTotalInOut";

  static String get getRejectApproval => "getRejectApproval";

  static String get getApproval => "getApproval";

  static String get getApprovalData => "getApprovalData";

  static String get login => "attendance_login";

  static String get target => "v1/target";

  static String get period => "v1/period";

  static String get getAllEmployeeAttendancesReport => "attendanceReport";

  static String get getCalenderReport => "calenderReport";

  static String get getAllEmployee => "getAllEmployee";
}
