import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geo_attendance_system/controllers/dashboard_controller.dart';
import 'package:geo_attendance_system/utils/date_time_formatter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/setting_controller.dart';
import '../database/DbHelper.dart';
import '../db/database.dart';
import '../main.dart';
import '../models/InData.dart';
import '../models/attendance_data.dart';
import '../res/strings.dart';
import '../utils/common.dart';
import '../utils/methods.dart';

class SyncService extends GetxService {
  final SharedPreferences _prefs = Get.find();
  var inProcess = false;
  var inProcess1 = false;
  Timer _timer;

  DbHelper _dbService = DbHelper();

  startSync() {
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      try {
        sendAttendanceDataServerCron(timer);
        fetchDataFromServerCron(timer);
      } on Exception catch (ex) {
        Common.toast("main.dart:LineNo-172${ex.toString()}");
        return;
      }
    });
  }

  void sendAttendanceDataServerCron(Timer timer) async {
    SharedPreferences sharedPreferences = Get.find();

    try {
      if(inProcess){
        return;
      }
      inProcess = true;
      int totalMTick;
       totalTick = sharedPreferences.getInt(Strings.totalTick);

      if (totalTick == null && totalMTick == null) {
        totalMTick = 0;
        totalTick = 0;
      } else {
        totalMTick = totalTick + timer.tick;
      }
      bool isSyncMin = (totalMTick % (1 * 2)) == 0;
      await sharedPreferences.setInt(
          Strings.totalTick, (totalTick + timer.tick));
        Get.find<DashboardController>().currentDateTime.value = DateTime.now();
      log("timerTick=${timer.tick},totalTick=$totalMTick");

      // if (kDebugMode) {
      //    Common.toast("tick-count=$totalMTick");
      // }
      if ((!isSyncing) && isSyncMin) {
        await sharedPreferences.setInt(Strings.totalTick, 0);
        updateSyncTime(sharedPreferences);
        isSyncing = true;
        final _connectivityResult = await (connectivity.checkConnectivity());
        if (_connectivityResult != ConnectivityResult.none) {
          Map<String, dynamic> body = Map();
          var records = await _dbService.getAllAttendanceRecordsString();
          if (records.length > 0) {
            body['faceData'] = records;
            await logSyncDetaInFile("\n${jsonEncode(body)}");
            dynamic response =
                await attendanceController.saveAttendanceOnServer(body);
            if (response['success']) {
              await _dbService.updateSyncSuccessfully();
              String lastSyncDateTime =
                  sharedPreferences.getString(Strings.lastSyncDate);

              if (lastSyncDateTime != null) {
                DateTime dtLastSyncDateTime = DateTimeFormatter
                    .displayDDMMYYHHMMSS
                    .parse(lastSyncDateTime);
                String todayDDMMYYString = DateTimeFormatter.displayDDMMYYHHMMSS
                    .format(DateTime.now());
                DateTime parsedDateTimeToday = DateTimeFormatter
                    .displayDDMMYYHHMMSS
                    .parse(todayDDMMYYString);
                if (!dtLastSyncDateTime.isAfter(parsedDateTimeToday)) {
                  DashboardController controller = Get.find();
                  await controller.moveAttendanceBackup();
                }
              }
            }
          } else {
            log(Strings.noInternetMsg);
          }
          isSyncing = false;
        }
      }
      inProcess = false;
    } on DioError catch (ex) {
      updateSyncTime(sharedPreferences);
      isSyncing = false;
      logErrorInFile(ex.toString());
    } on FormatException catch (ex) {
      updateSyncTime(sharedPreferences);
      logErrorInFile(ex.toString());
      isSyncing = false;
    } on Exception catch (ex) {
      updateSyncTime(sharedPreferences);
      logErrorInFile(ex.toString());
      isSyncing = false;
    }
    finally{
      isSyncing = false;
    }
  }

  void updateSyncTime(SharedPreferences sharedPreferences) async {
    String dateString =
        DateTimeFormatter.displayDDMMYYHHMMSS.format(DateTime.now());
    await sharedPreferences.setString(Strings.lastSyncDate, dateString);
  }

  void fetchDataFromServerCron(Timer timer) async {
    try {
      if(inProcess1){
        return;
      }
      inProcess1 = true;
      bool isFetchData = (timer.tick % ((60 * 7) + 30)) == 0;

      if (isFetchData && (!isSyncing)) {
        DataBaseService apiService = DataBaseService();
        Map<String, dynamic> body = {};
        isSyncing = true;

        body['f_date'] = DateFormat("yyyy-MM-dd").format(DateTime.now());
        body['t_date'] = DateFormat("yyyy-MM-dd").format(DateTime.now());
        body['acceptance'] = 1;

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        Get.put(sharedPreferences);
        Get.put(SettingController());

        AttendanceData data = await apiService.getAttendanceData(body);

        if (data != null) {
          List<InData> inData = data.data.inData;
          inData.addAll(data.data.outData);

          inData.forEach((element) {
            int type = 0;
            Map<String, dynamic> record = element.toJson();
            record.removeWhere((key, value) {
              return (key == "created_at" || key == "updated_at");
            });
            type = element.type == "IN" ? 0 : 1;
            _dbService.insertAttendance(record, 0, element.empId, element.time,
                InOut: type, isServer: true);
          });
        }

        body['acceptance'] = 0;

        data = await apiService.getAttendanceData(body);

        if (data != null) {
          List<InData> inData = data.data.inData;
          inData.addAll(data.data.outData);

          inData.forEach((element) {
            int type = 0;
            Map<String, dynamic> record = element.toJson();
            record.removeWhere((key, value) {
              return (key == "created_at" || key == "updated_at");
            });
            type = element.type == "IN" ? 0 : 1;
            _dbService.insertAttendance(record, 0, element.empId, element.time,
                InOut: type, isServer: true);
          });
        }

        isSyncing = false;
        inProcess1 = false;
      }
    } on Exception catch (ex) {
      isSyncing = false;
      if (kDebugMode) {}
    }
    finally{
      isSyncing = false;
      inProcess1 = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    if (_timer.isActive) {
      _timer.cancel();
    }
  }
}
