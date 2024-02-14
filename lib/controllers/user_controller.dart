import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:external_path/external_path.dart';
import 'package:geo_attendance_system/controllers/dashboard_controller.dart';
import 'package:geo_attendance_system/db/database.dart';
import 'package:geo_attendance_system/res/strings.dart';
import 'package:geo_attendance_system/service/facenet.service.dart';
import 'package:geo_attendance_system/ui/VisionDetectorViews/face_detector_view.dart';
import 'package:geo_attendance_system/utils/auth/auth_manager.dart';
import 'package:geo_attendance_system/utils/common.dart';
import 'package:geo_attendance_system/utils/enums.dart';
import 'package:geo_attendance_system/utils/methods.dart';
import 'package:geo_attendance_system/utils/shared_pref_manager/sp_keys.dart';
import 'package:get/get.dart';

// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../service/LocalNotificationService.dart';

class UserController extends GetxController {
  DataBaseService _dataBaseService;
  bool isFetchLocation = true;
  final prevEmpId = "".obs;

  @override
  void onInit() async {
    _dataBaseService = DataBaseService();
    await _dataBaseService.loadDB();
    super.onInit();
  }

  Future<void> deleteUser(String mkey, {int isActive}) async {
    try {
      await _dataBaseService.loadDB();
      await Future.delayed(Duration(milliseconds: 200));
      MapEntry mvalue = _dataBaseService.db.entries
          .firstWhere((element) => element.key == mkey);
      dynamic value = mvalue.value;
      print("response={$value}");
      value['is_active'] = isActive;
      print("response={$value}");
      _dataBaseService.db.update(mkey, (value) => value);
      print("response=${json.encode(_dataBaseService.db)}");
      await _dataBaseService.writeDB(_dataBaseService.db,
          action: isActive == UserType.inactive.index
              ? SPKeys.deactivateUser.toString()
              : SPKeys.activeUser.toString());
      // log(_dataBaseService.db);

    } catch (ex) {
      print(ex.toString());
    }
  }

  Future<void> generateExampleDocument(
      List<Map<String, dynamic>> userList) async {
    String path;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    final LocalNotificationService localNotification = Get.find();

    log(statuses);
    if (userList.isNotEmpty) {
      List<List<dynamic>> rows = [];

      List<dynamic> row = [];
      row.add("Sr No");
      row.add("User Name");
      row.add("Emp Id");
      row.add("Active/DeActive");
      rows.add(row);

      print("userList :: $userList");

      for (int i = 0; i < userList.length; i++) {
        List<dynamic> row = [];
        row.add(i + 1);
        row.add(userList[i]['key'].split(":")[0]);
        row.add(userList[i]['key'].split(":")[1]);

        row.add(userList[i]['is_active'] == 1 ? "Active" : "DeActive");
        // row.add(userList[i]['is_active']) ;

        rows.add(row);
      }
      // List<dynamic> row1 = [];
      // row1.add("Total Amount");
      // row1.add("");
      // row1.add("");
      // row1.add("");
      // row1.add("");
      // // row1.add(reportController.accountLedgerModal.value.totalAmount +
      // //     reportController.accountLedgerModal.value.pendingAmount);
      //
      // rows.add(row1);

      String csv = const ListToCsvConverter().convert(rows);

      path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
      print("dir $path");
      String file = path;

      File f = File(file +
          "/usersDataReport_${DateFormat("yyyy-dd-M--HH-mm-ss").format(DateTime.now())}.csv");
      if (!f.existsSync()) {
        f.createSync();
      }

      Timer.periodic(Duration(microseconds: 1), (timer) async {
        String fileString = await f.readAsString();
        double percentage = ((fileString.length / csv.length) * 100);

        if (percentage < 0.99) {
          localNotification.showLocal(Strings.downloading, "$percentage",
              payloadMsg: {"path": f.path});
        } else {
          localNotification.showLocal(Strings.downloading, "100%",
              payloadMsg: {"path": f.path});
          timer.cancel();
        }
      });

      f.writeAsString(csv);

      Common.toast(Strings.downloaded_successfully);
    } else {
      Common.toast(Strings.noRecordsFound);
    }
  }

  void navigateToScanFace(String empId, String name,
      FaceNetService faceNetService, FaceDetector faceDetector,
      {bool isSignUp = false, bool isEdit = false}) {
    Get.to(() => FaceDetectorView(
          name,
          empId,
          isSignUp,
          faceDetector,
          faceNetService,
          empId: empId,
          isEdit: isEdit,
          isAuto: false,
        )).then((value) {
      try {
        bool isSignUp = value["isSignUp"];
        bool error = value["error"];
        File file = value["image"] as File;
        var result = value["result"];
        if (result != null) {
          empId = result;
        }
        if (isSignUp && !error) {
          Common.toast(Strings.userAddedSuccessfully);
        } else if (result != null) {
          if (int.parse(empId) == AuthManager().getLoginData().data.id) {
          } else {
            Common.toast(Strings.invalid_employee);
          }
        } else {
          Common.toast(Strings.userNotExits);
        }
      } catch (ex) {}
    });
  }

  void navigateToScanFaceEmpolyee(String empId, String name,
      FaceNetService faceNetService, FaceDetector faceDetector,
      {bool isSignUp = false, bool isEdit = false}) {
    Get.to(() => FaceDetectorView(
          name,
          empId,
          isSignUp,
          faceDetector,
          faceNetService,
          empId: empId,
          isEdit: isEdit,
          isAuto: false,
        )).then((value) {
      try {
        bool isSignUp = value["isSignUp"];
        bool error = value["error"];
        File file = value["image"] as File;
        var result = value["result"];
        if (result != null) {
          empId = result;
        }
        print("empi ID :: $result");

        if (isSignUp && !error) {
          Common.toast(Strings.userAddedSuccessfully);
        } else if (result != null) {
          if (int.parse(empId) == AuthManager().getLoginData().data.id) {
          } else {
            Common.toast(Strings.invalid_employee);
          }
        } else {
          Common.toast(Strings.userNotExits);
        }
      } catch (ex) {}
    });
  }

  Future<void> EditDetails(String username, String empId, String user) async {
    try {
      String newKeyValue = username + ":${int.parse(empId)}";
      DashboardController dashboardController = Get.find();
      await _dataBaseService.loadDB();
      await Future.delayed(Duration(milliseconds: 200));
      dynamic temp = _dataBaseService.db[user];
      _dataBaseService.db.removeWhere((key, value) => key == user);
      _dataBaseService.db[newKeyValue] = temp;
      dashboardController.empIdController.clear();
      dashboardController.usernameController.clear();
      await _dataBaseService.writeDB(_dataBaseService.db,
          action: SPKeys.editUser.toString());
    } catch (ex) {
      log(ex.toString());
    }
  }

  // int getEmployeeId(){
  //   return AuthManager().getLoginData().data.first.employeeId;
  // }
//
  bool getIsEmployeeIdExits(String empId, String flag, bool isEdit,
      {String prevEmpId}) {
    Map<String, dynamic> data = _dataBaseService.db;
    for (String label in data.keys) {
      if (flag == Strings.empId) {
        if (int.parse(label.toLowerCase().split(":")[1]) == int.parse(empId)) {
          if (isEdit) {
            if (prevEmpId != label.split(":")[1])
              return true;
            else
              return false;
          } else {
            return true;
          }
        }
      } else {
        if (label.toLowerCase().split(":")[0].toLowerCase() ==
            empId.toLowerCase()) {
          return true;
        }
      }
    }
    return false;
  }
}
