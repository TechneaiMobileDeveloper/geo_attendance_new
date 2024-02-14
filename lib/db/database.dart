import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geo_attendance_system/controllers/setting_controller.dart';
import 'package:geo_attendance_system/models/attendance_data.dart';
import 'package:geo_attendance_system/models/attendances_report/attendances_report_model.dart';
import 'package:geo_attendance_system/network/api_client.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geo_attendance_system/models/attendance_data_1.dart';

class DataBaseService {
  // singleton boilerplate

  static const int databaseVersion = 2;

  static final DataBaseService _cameraServiceService =
      DataBaseService._internal();

  factory DataBaseService() {
    return _cameraServiceService;
  }

  // singleton boilerplate
  DataBaseService._internal();

  /// file that stores the data on filesystem
  File jsonFile;
  File locationFile;

  /// Data learned on memory
  Map<String, dynamic> _db = Map<String, dynamic>();
  Map<String, dynamic> mLocation = Map<String, dynamic>();

  Map<String, dynamic> get db => this._db;

  Map<String, dynamic> get location => this.mLocation;

  Future loadDB() async {
    try {
      String url = AppUrl.urlFaceBase() + AppUrl.getFaceData;
      print("user url :: $url");
      APIClient apiClient = APIClient();
      final response = await apiClient.get(url);
      _db = response;
      print("response user :: $_db");
    } catch (ex) {
      logErrorInFile(ex.toString());
      log(ex.toString());
    }
  }

  Future loadLocations() async {
    try {
      var tempDir = await getExternalStorageDirectory();
      String _embPath =
          tempDir.path + "/location${getCurrentDate("ddMMyyyy")}.json";
      locationFile = new File(_embPath);
      if (locationFile.existsSync()) {
        mLocation = json.decode(locationFile.readAsStringSync());
      }
    } catch (ex) {
      logErrorInFile(ex.toString());
    }
  }

  String getCurrentDate(String format) {
    DateFormat dt = DateFormat(format);
    return dt.format(DateTime.now());
  }

  /// [Name]: name of the new user
  /// [Data]: Face representation for Machine Learning model
  ///
  Future saveData(String user, String password, List modelData,
      {bool isConflict = false}) async {
    try {
      int empId = int.parse(password);
      String userAndPass = user + ":$empId"; //
      Map<String, dynamic> body = Map();
      await loadDB();
      Map<String, dynamic> data = {
        "faceData": modelData,
        "is_active": UserType.active.index
      };
      _db[userAndPass] = data;
      String url = AppUrl.urlFaceBase() + AppUrl.addFaceData;
      APIClient apiClient = APIClient();
      body['faceData'] = json.encode(_db);
      //TODO
      final response = await apiClient.post(url, data: body);
      Common.toast(response["message"]);
    } catch (ex) {
      logErrorInFile(ex.toString());
      log(ex.toString());
    }

    // var tempDir = await getExternalStorageDirectory();
    //
    // String _embPath = tempDir.path + '/emb.json';
    //
    // jsonFile = new File(_embPath);
    // _db[userAndPass] = modelData;
    //sa
    // if(jsonFile.existsSync()) {
    //    jsonFile.writeAsStringSync(json.encode(_db));
    // }
    // else {
    //    jsonFile.createSync();
    //    jsonFile.writeAsStringSync(json.encode(_db));
    // }
  }

  /// deletes the created users
  cleanDB() {
    try {
      this._db = Map<String, dynamic>();
      jsonFile.writeAsStringSync(json.encode({}));
    } catch (ex) {
      logErrorInFile(ex.toString());
    }
  }

  writeDB(Map<String, dynamic> data, {String action}) async {
    try {
      Map<String, dynamic> body = Map();
      // todo
      String url = AppUrl.urlFaceBase() + AppUrl.addFaceData;

      APIClient apiClient = APIClient();
      body['faceData'] = json.encode(data);

      await apiClient.post(url, data: body);

      if (action == SPKeys.editUser.toString()) {
        Common.toast(Strings.editUserSuccessfully);
      } else if (action == SPKeys.activeUser.toString()) {
        Common.toast(Strings.activedUser);
      } else if (action == SPKeys.deactivateUser.toString()) {
        Common.toast(Strings.deactivedUser);
      }
    } catch (ex) {
      logErrorInFile(ex.toString());
    }
  }

  getAttendanceData(Map params, {bool isTodayApproved = false}) async {
    try {
      print("getAttendances Data :: $isTodayApproved  :: body $params");
      final settingController = Get.find<SettingController>();
      bool isInternet = await hasNetwork();
      APIClient apiClient = APIClient();
      String url = await getIpAddress(settingController: settingController);
      if (!isTodayApproved) {
        url = url + AppUrl.getAttendance;
        print("URL API isTodayApproved $url");
        if (isInternet) {
          Map<String, dynamic> response = await apiClient.post(url, queryParameters: params);
          print("response IN OUT:: $response");
          return AttendanceData.fromJson(response);
        } else {
          Common.toast(Strings.noInternetMsg);
          return null;
        }
      } else {
        url = url + AppUrl.todayApprovalReport;
        if (isInternet)
            {
          Map<String, dynamic> response =
              await apiClient.get(url, queryParameters: params);

          print("response IN OUT:: $response");

          return AttendanceDataModel.fromJson(response);
        }
        else
            {
          Common.toast(Strings.noInternetMsg);
          return null;
        }
      }

      // if (isInternet) {
      //   Map<String, dynamic> response =
      //       await apiClient.post(url, queryParameters: params);
      //
      //   print("response IN OUT:: ${response}");
      //   return AttendanceData.fromJson(response);
      // } else {
      //   Common.toast(Strings.noInternetMsg);
      //   return null;
      // }
    } catch (ex) {
      logErrorInFile(ex.toString());
      print("loc ::${ex.toString()}");
      print(ex.toString());

      return null;
    }
  }

  getAttendanceDataReport(Map params, {bool isTodayApproved = false}) async {
    try {
      print("getAttendances Data vadd:: $isTodayApproved  :: body $params");
      final settingController = Get.find<SettingController>();
      bool isInternet = await hasNetwork();
      APIClient apiClient = APIClient();
      String url = await getIpAddress(settingController: settingController);

      if (!isTodayApproved) {
        url = url + AppUrl.getAttendance;
        print("URL API isTodayApproved $url");
        if (isInternet) {
          Map<String, dynamic> response =
              await apiClient.post(url, queryParameters: params);
          print("response IN OUT:: $response");
          AttendanceDataModel model = AttendanceDataModel.fromJson(response);
          return model;
        } else {
          Common.toast(Strings.noInternetMsg);
          return null;
        }
      } else {
        url = url + AppUrl.todayApprovalReport;
        print("URL API todayApprovalReport $url");

        if (isInternet) {
          Map<String, dynamic> response =
              await apiClient.get(url, queryParameters: params);
          print("response IN OUT:: $response");
          return AttendanceDataModel.fromJson(response);
        } else {
          Common.toast(Strings.noInternetMsg);
          return null;
        }
      }

      // if (isInternet) {
      //   Map<String, dynamic> response =
      //       await apiClient.post(url, queryParameters: params);
      //
      //   print("response IN OUT:: ${response}");
      //   return AttendanceData.fromJson(response);
      // } else {
      //   Common.toast(Strings.noInternetMsg);
      //   return null;
      // }
    } catch (ex) {
      logErrorInFile(ex.toString());
      print("loc ::${ex.toString()}");
      print(ex.toString());

      return null;
    }
  }

  Future<AttendanceReportModel> getAllEmployeeAttendanceReportData(Map params,
      {bool isTodayApproved = false}) async {
    try {
      final settingController = Get.find<SettingController>();
      bool isInternet = await hasNetwork();

      String url = await getIpAddress(settingController: settingController);

      if (!isTodayApproved) {
        url = url + AppUrl.getAllEmployeeAttendancesReport;
        print("URL API $url");
      } else {
        url = url + AppUrl.getAllEmployeeAttendancesReport;
        print("URL API Report $url");
      }

      APIClient apiClient = APIClient();
      print("response Reports:: $params");

      if (isInternet) {
        Map<String, dynamic> response =
            await apiClient.post(url, queryParameters: params);

        print("response Reports:: $response");

        return AttendanceReportModel.fromJson(response);
      } else {
        Common.toast(Strings.noInternetMsg);
        return null;
      }
    } catch (ex) {
      logErrorInFile(ex.toString());
      print(ex.toString());

      return null;
    }
  }

  getAllEmployeeAttendanceReportDataValue(Map params,
      {bool isTodayApproved = false}) async {
    try {
      final settingController = Get.find<SettingController>();
      bool isInternet = await hasNetwork();

      String url = await getIpAddress(settingController: settingController);

      // if (!isTodayApproved) {
      url = url + AppUrl.getAllEmployeeAttendancesReport;
      print("URL API $url");
      // } else {
      //   url = url + AppUrl.getAllEmployeeAttendancesReport;
      //   print("URL API Report $url");
      // }

      APIClient apiClient = APIClient();
      print("response Reports:: $params");

      if (isInternet) {
        Map<String, dynamic> response =
            await apiClient.post(url, queryParameters: params);
        print("response Reports:: $response");
        return AttendanceDataModel.fromJson(response);
      } else {
        Common.toast(Strings.noInternetMsg);
        return null;
      }
    } catch (ex) {
      logErrorInFile(ex.toString());
      print(ex.toString());

      return null;
    }
  }

  saveLocation(String location, String dateTime) async {
    try {
      var tempDir = await getExternalStorageDirectory();
      String _embPath =
          tempDir.path + "/location${getCurrentDate("ddMMyyyy")}.json";
      await loadLocations();

      locationFile = new File(_embPath);

      if (locationFile.existsSync()) {
        mLocation[dateTime] = location;
        locationFile.writeAsStringSync(json.encode(mLocation));
      } else {
        locationFile.createSync();
        mLocation.clear();
        mLocation[dateTime] = location;
        locationFile.writeAsStringSync(json.encode(mLocation));
      }
    } catch (ex) {
      logErrorInFile(ex.toString());
    }
  }

  Future<int> getEmployeeData(String empId) async {
    try {
      Map<String, dynamic> queryParams = {};
      bool isInternet = await hasNetwork();
      String validationEmp = AppUrl.validateEmployee;
      //TODO
      String url = "${AppUrl.urlBase()}${AppUrl.subPath()}$validationEmp";

      if (isInternet) {
        APIClient apiClient = APIClient();
        queryParams['emp_id'] = empId;
        dynamic response = await apiClient.get(url, queryParameters: queryParams);
        return response['success'] ? 1 : 0;
      } else {
        return 0;
      }
    } catch (ex) {
      logErrorInFile(ex.toString());
    }
  }

  Future<Map<String, dynamic>> getEmployeeFaceData(String empId) async {
    try {
      Map<String, dynamic> queryParams = {};
      bool isInternet = await hasNetwork();
      String url = "${AppUrl.urlBase()}${AppUrl.empId}";
      if (isInternet) {
        APIClient apiClient = APIClient();
        queryParams['emp_id'] = empId;
        dynamic response =
            await apiClient.get(url, queryParameters: queryParams);
        return response;
      } else {
        return {};
      }
    } catch (ex) {
      return {};
    }
  }

  Future<bool> approveAttendance(
      int empId, String date, String type, String time) async {
    print("hiii $type");
    print("hiii $empId");
    print("hiii $date");
    try {
      print("hii");
      Map<String, dynamic> queryParams = {};
      bool isInternet = await hasNetwork();
      String url =
          "${AppUrl.urlBase()}${AppUrl.subDummyPath()}${AppUrl.getApprovalData}";
      print("approval ::: $url");
      if (isInternet) {
        APIClient apiClient = APIClient();
        queryParams['emp_id'] = empId;
        queryParams['date'] = date;
        queryParams['type'] = type;
        queryParams['time'] = time;
        dynamic response =
            await apiClient.post(url, queryParameters: queryParams);
        print("response approval :: $response");
        Common.toast(response['message']);
        return response['success'];
      } else {
        return false;
      }
    } catch (ex) {
      if (kDebugMode) {
        print("db/database=${ex.toString()}");
      }
    }
  }

  // Future<void> checkDatabaseUpgraded() async{
  //    try{
  //      int localDbVersion;
  //      SharedPreferences sharedPreferences = Get.find();
  //      if(sharedPreferences.getInt(Strings.databaseVersion) != null){
  //        localDbVersion = sharedPreferences.getInt(Strings.databaseVersion);
  //        if(localDbVersion < databaseVersion){
  //            await onUpgrade();
  //         }
  //        else{
  //            await onUpgrade();
  //        }
  //      }
  //      else{
  //          await  onUpgrade();
  //      }
  //    }catch(ex){
  //     print(ex.toString());
  //    }
  // }

  Future<void> onUpgrade() async {
    await updateLocalDbVersion(databaseVersion);
  }

  Future<void> updateLocalDbVersion(int version) async {
    try {
      // SharedPreferences sharedPreferences = Get.find();
      // await sharedPreferences.setInt(Strings.databaseVersion, version);
      // Map<String,dynamic> body = {};
      // Map<String, dynamic> newObj = {};
      // int index=0;
      // for (dynamic value in _db.values) {
      //
      //         newObj[key] = value;
      //       }
      //       index = index+1;
      // }
      //  _db = newObj;

      writeDB(_db, action: SPKeys.editUser.toString());
    } catch (ex) {
      log(ex.toString());
    }
  }

  rejectAttendance(int empId, String cDate, String type, String time) async {
    try {
      Map<String, dynamic> queryParams = {};
      //  final settingController = Get.find<SettingController>();

      bool isInternet = await hasNetwork();
      String url = await getIpAddress() + AppUrl.getRejectApproval;
      print("reject url $url");
      if (isInternet) {
        APIClient apiClient = APIClient();
        queryParams['emp_id'] = empId;
        queryParams['date'] = cDate;
        queryParams['type'] = type;
        queryParams['time'] = time;
        dynamic response =
            await apiClient.post(url, queryParameters: queryParams);

        print("reject $response");
        return response['success'];
      } else {
        return false;
      }
    } catch (ex) {
      if (kDebugMode) {
        print(ex.toString());
      }
    }
  }
}

class GetEmployee {}
