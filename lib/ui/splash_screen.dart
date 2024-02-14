import 'dart:async';
import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geo_attendance_system/controllers/attendance_controller.dart';
import 'package:geo_attendance_system/controllers/dashboard_controller.dart';
import 'package:geo_attendance_system/controllers/setting_controller.dart';
import 'package:geo_attendance_system/database/DbHelper.dart';
import 'package:geo_attendance_system/main.dart';
import 'package:geo_attendance_system/mixins/after_layout.dart';
import 'package:geo_attendance_system/network/api_client.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/services/fetchDataService.dart';
import 'package:geo_attendance_system/services/sync_service.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../app.dart';
import '../service/LocalNotificationService.dart';

const Duration splashDuration = Duration(seconds: 3);

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with AfterLayoutMixin<SplashScreen> {
  DbHelper _dbService = DbHelper();
  final _connectivity = Connectivity();
  final attendanceController = Get.put(AttendanceController());

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    await _setupDependency();
    await _startApp();
  }

  @override
  void initState() {
    // TODO: implement initState
    // initMethod();
    // onStart();
    super.initState();
  }

  // void onStart() {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   final service = FlutterBackgroundService();
  //   service.onDataReceived.listen((event) {
  //     if (event["action"] == "setAsForeground") {
  //       service.setAsForegroundService();
  //       return;
  //     }
  //
  //     if (event["action"] == "setAsBackground") {
  //       service.setAsBackgroundService();
  //     }
  //
  //     if (event["action"] == "stopService") {
  //       service.stopService();
  //     }
  //   });
  //
  //   // bring to foreground
  //   service.setAsForegroundService();
  //
  //   print("appService:My App Service");
  //
  //   Timer.periodic(Duration(minutes: 1), (timer) async {
  //     if (!(await service.isRunning())) timer.cancel();
  //     String location;
  //     int tick;
  //     service.setNotificationInfo(
  //       title: Strings.appName,
  //       content: "Updated at $location",
  //     );
  //     service.sendData(
  //       {"current_date": DateTime.now().toIso8601String()},
  //     );
  //
  //     tick = timer.tick;
  //
  //     if (tick % 1 == 0) {
  //       final _connectivityResult = await (_connectivity.checkConnectivity());
  //       if (_connectivityResult != ConnectivityResult.none) {
  //         Map<String, dynamic> body = Map();
  //         body['faceData'] = await _dbService.getAllAttendanceRecordsString();
  //         await attendanceController.saveAttendanceOnServer(body);
  //       } else {
  //         log(Strings.noInternetMsg);
  //       }
  //     }
  //   });
  // }

  _setupDependency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Get.put(preferences);
    totalTick = preferences.getInt(Strings.totalTick);
    cameras = await availableCameras();
    //Services
    Get.put(AuthManager());
    Get.put(APIClient());
    Get.put(DashboardController(true));
    Get.put(FetchDataService());
    Get.put(SettingController());
    Get.put(LocalNotificationService());
    Get.put(SyncService()).startSync();
  }

  _startApp() async {
    await _checkForPermissions();
    return Timer(splashDuration, () async {
      Location locationService = new Location();
      bool _serviceEnabled;
      _serviceEnabled = await locationService.serviceEnabled();
      if (_serviceEnabled) {
        redirect(_serviceEnabled);
      } else {
        bool response = await locationService.requestService();
        redirect(response);

        // if(response){
        //   Get.find<AuthManager>().redirectUser();
        // }
        // else{
        //   Common.toast(Strings.needLocationAccess);
        // }
      }
    });
  }

  redirect(bool response) async {
    if (response) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (preferences.getBool(SPKeys.isFirst.value) ?? true) {
        preferences.setInt(Strings.databaseVersion, 1);
        Get.find<AuthManager>().redirectUser(level: false); // true is user
      } else {
        Get.find<AuthManager>().redirectUser(level: false);
      }
    } else {
      Common.toast(Strings.needLocationAccess);
    }
  }

  //
  Future<void> _checkForPermissions() async {
    bool cameraStatus = await Permission.camera.request().isGranted;
    bool notification = await Permission.notification.request().isGranted;
    bool microPhoneStatus = await Permission.microphone.request().isGranted;
    bool storageStatus = await Permission.storage.request().isGranted;
    bool location = await Permission.location.request().isGranted;
    bool callStatus =
        Platform.isAndroid ? await Permission.phone.request().isGranted : true;
    Location locationService = new Location();
    bool _serviceEnabled;
    _serviceEnabled = await locationService.serviceEnabled();
    if (_serviceEnabled) {
      if (callStatus &&
          notification &&
          storageStatus &&
          cameraStatus &&
          microPhoneStatus &&
          location) {
        await Get.find<AuthManager>().redirectUser();
      } else {
        Get.find<AuthManager>().redirectUser(level: false);
      }
    } else {
      dynamic response = await locationService.requestService();
      if (response) {
        if (callStatus &&
            notification &&
            storageStatus &&
            cameraStatus &&
            microPhoneStatus &&
            location) {
          await Get.find<AuthManager>().redirectUser();
        } else {
          Get.find<AuthManager>().redirectUser(level: false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      ScreenUtil.init(context,
          designSize: Size(Get.width, Get.height), splitScreenMode: false);
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Image(
              image: AssetImage(Assets.techAi),
              height: Sizes.s200,
              width: Sizes.s200),
        ),
      );
    });
  }

  void initMethod() async {
    final int helloAlarmID = 0;
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.periodic(
        const Duration(minutes: 1), helloAlarmID, printHello);
  }
}
