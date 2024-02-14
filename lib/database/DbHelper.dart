import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geo_attendance_system/ui/constants/strings.dart';
import 'package:geo_attendance_system/utils/common.dart';
import 'package:geo_attendance_system/utils/date_time_formatter.dart';
import 'package:geo_attendance_system/utils/methods.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import '../controllers/report_controller.dart';
import '../res/strings.dart';

class DbHelper extends GetxController {
  String db = "geo_attendance.db";
  String tbl_attendance = "tbl_attendance";
  String tbl_attendance_backup = "tbl_attendance_backup";
  String tbl_trancking = "tbl_tracking_records";
  String createAttendanceTable =
      "CREATE TABLE tbl_attendance(id integer PRIMARY KEY AUTOINCREMENT,emp_id "
      "INTEGER,c_date TEXT,time TEXT,attendance_type TEXT,lat TEXT,lon TEXT,image_path TEXT, "
      "acceptance INTEGER default 1,isSync INTEGER default 0,userName VARCHAR(255) default null,type TEXT,location TEXT )";

  String createAttendanceTableBackUp =
      "CREATE TABLE tbl_attendance_backup(id integer PRIMARY KEY AUTOINCREMENT,emp_id "
      "INTEGER,c_date TEXT,time TEXT,attendance_type TEXT,lat TEXT,lon TEXT,image_path TEXT, "
      "acceptance INTEGER default 1,isSync INTEGER default 0,userName VARCHAR(255) default null,type TEXT,location TEXT )";


  String createInOutDetailsTable =
      "CREATE TABLE tbl_attendance(id integer PRIMARY KEY AUTOINCREMENT,emp_id integer,c_date TEXT,inTime TEXT,OutTime TEXT )";

  String createTrackingRecords =
      "CREATE TABLE tbl_tracking_records(id integer PRIMARY KEY AUTOINCREMENT,emp_id integer,c_date TEXT,dateTime TEXT,Location TEXT)";
  Database _database;

  final inOutCount = [].obs;
  final dashboardContent = {}.obs;

  @override
  void onInit() async {
    _database = await openAppDatabase();
  }

  Future<Database> openAppDatabase() async {
    final database = await openDatabase(
      p.join(await getDbPath(), db),
      onCreate: (db, version) async {
        await db.execute(createAttendanceTable);
        await db.execute(createAttendanceTableBackUp);
      },
      onUpgrade: (db, oldVersion, newversion) {
        if (oldVersion <= 4) {
          db.execute(
              "ALTER TABLE $tbl_attendance ADD COLUMN out_date TEXT default null");
        }
      },
      version: 5,
    );
    return database;
  }

  getDbPath() async {
    String path;
    path = await getDatabasesPath();
    return path;
  }

  insertAttendanceRecords(String date) async {
    // ReportController reportController = Get.put(ReportController(true));
    //  await reportController.getAttendanceData(tDate: DateFormat("dd-MM-yyyy")
    //         .format(DateTime.now()),fDate: DateFormat("dd-MM-yyyy")
    //         .format(DateTime.now())
    //        );
    // _database = await openAppDatabase();
    //   List<Data> list =  reportController.attendanceData.value.data;
    //   List<Map<String,dynamic>> mapList=  list.map((value)=>value.toJson()).toList();
    // for(int i=0;i<mapList.length;i++) {
    //   await _database.transaction((txn) async {
    //         txn.insert(tbl_attendance, mapList[i]);
    //   });
    // }
  }

  insertAttendance(Map<String, dynamic> record, int flag, int empId, String currentTime,
      {int InOut = 0, bool isServer = false}) async {
    try {
      var alreadyPunch;
      int type;
      alreadyPunch = await getIsPunched(empId,
          time: currentTime, record: record, Inout: InOut, isServer: isServer);
      alreadyPunch = alreadyPunch['type'];

      // alreadyPunch = IN Only Out will do
      if (alreadyPunch == "IN") {
        type = 0;
      }

      // else if isServer = true && alreadyPunch = "First" - Insert Any Where with compare
      else if (isServer && alreadyPunch == "FIRST") {
        type = 2;
      } else {
        type = 1;
      }

      if (InOut != type) {
        await _database.transaction((txn) async {
          return await txn.insert(tbl_attendance, record).then((value) {
            String message;
            if (InOut == 0) {
              message = punch_in_successfully;
            } else {
              message = punch_out_successfully;
            }

            if (!isServer) {
              Common.toast(
                  "$message on Date=${DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now())}");
            }
          }, onError: (error) {
            print(error.toString());
          });
        });

        return 0;
      } else {
        return 1;
      }
    } catch (ex) {
      logErrorInFile(ex.toString());
      log("Dbheloper:${ex.toString()}");
    }
  }

  getIsPunched(int empId,
      {String time,
      Map<String, dynamic> record,
      int Inout = 0,
      bool isServer = false}) async {
    try {
      Map<String, dynamic> flag;
      Map<String, dynamic> out = Map();
      String query;

      _database = await openAppDatabase();
      String filterString = "";
      String cDate = await getCurrentDate("yyyy-MM-dd");
      if (isServer) {
        filterString = " and time='$time'";
      }
      if (Inout == 0) {
        query =
            "SELECT type FROM $tbl_attendance where emp_id=$empId and c_date='$cDate'$filterString order by id desc limit 1";
      } else {
        query =
            "SELECT type FROM $tbl_attendance where emp_id=$empId $filterString order by id desc limit 1";
      }

      flag = await _database.transaction((txn) async {
        var result = await txn.rawQuery(query);
        if (result.length > 0) {
          out['type'] = result.first['type'];
        } else {
          out['type'] = "FIRST";
        }
        return out;
      });

      return flag;
    } catch (ex) {
      logErrorInFile(ex.toString());
    }
  }

  Future<Map<String, dynamic>> getTimes(int empId) async {
    try {
      _database = await openAppDatabase();
      Map<String, dynamic> record;
      String query =
          "SELECT time,type FROM $tbl_attendance where c_date='${getCurrentDate("yyyy-MM-dd")}' and emp_id=$empId order by id desc";
      record = await _database.transaction((txn) async {
        Map<String, dynamic> row;
        var result = await txn.rawQuery(query);
        if (result != null) {
          row = Map();
          row["inTime"] = result.first["time"];
          if (result.last['type'] == "OUT") {
            row["OutTime"] = result.last["time"];
          } else {
            row["OutTime"] = null;
          }
        }
        return row;
      });
      return record;
    } catch (ex) {
      logErrorInFile(ex.toString());
      log(ex.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getAllRecords(
      {String fDate, String tDate, int empId}) async {
    try {
      List<Map<String, dynamic>> records;
      String query;
      _database = await openAppDatabase();
      if (fDate == null && tDate == null)
        query = "SELECT * FROM " +
            tbl_attendance +
            " where c_date != '${getCurrentDate("yyyy-MM-dd")}' order by c_date desc limit 6 ";
      else
        query = "SELECT * FROM " +
            tbl_attendance +
            " where c_date between '$fDate' and '$tDate' order by c_date desc";
      records = await _database.transaction((txn) {
        return txn.rawQuery(query);
      });
      return records;
    } catch (ex) {
      logErrorInFile(ex.toString());
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceReport(
      {String fDate, String tDate}) async {
    try {
      List<Map<String, dynamic>> records;
      String query;
      _database = await openAppDatabase();
      if (fDate == null && tDate == null)
        query = "SELECT c_date,emp_id,inTime,OutTime FROM " +
            tbl_attendance +
            " where c_date != '${getCurrentDate("yyyy-MM-dd")}' order by c_date desc limit 30 ";
      else
        query = "SELECT c_date,emp_id,inTime,OutTime FROM " +
            tbl_attendance +
            " where c_date between '$fDate' and '$tDate' order by c_date desc";
      records = await _database.transaction((txn) async {
        return await txn.rawQuery(query);
      });
      return records ?? [];
    } catch (ex) {
      logErrorInFile(ex.toString());
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllAttendanceRecordsString(
      {bool forBackup = false}) async {
    try {
      var isSync = "";
      List<Map<String, dynamic>> records = [];
      _database = await openAppDatabase();
      String inlineQueryString;

      if (!forBackup) {
        isSync = "0";
        inlineQueryString = "c_date as date";
      } else {
        isSync = "1";
        inlineQueryString = "c_date,lat,lon,userName,isSync";
      }

      String query =
          "SELECT emp_id,$inlineQueryString,time,type,location,image_path,acceptance FROM " +
              tbl_attendance +
              " where isSync = $isSync order by c_date desc";
      if (kDebugMode) {
        print("query ... $query");
      }
      records = await _database.transaction((txn) async {
        List<Map<String, dynamic>> response = await txn.rawQuery(query);
        return response;
      });
      return records;
    } catch (ex) {
      logErrorInFile(ex.toString());
      return [];
    }
  }

  Future<String> getAllLocationRecordsString() async {
    try {
      String records;
      _database = await openAppDatabase();
      String query = "SELECT * FROM " +
          tbl_trancking +
          " where c_date = ${getCurrentDate("yyyy-MM-dd")} order by c_date desc";
      records = await _database.transaction((txn) async {
        var response = await txn.rawQuery(query);
        return json.encode(response);
      });
      return records;
    } catch (ex) {
      logErrorInFile(ex.toString());
      return json.encode([]);
    }
  }

  Future<void> getDashboardContain() async {
    try {
      final reportController = Get.put(ReportController(false));
      await getPunchInAndPunchOutCount(reportController);
      dashboardContent[Strings.punchInCount] = inOutCount[0];
      dashboardContent[Strings.punchOutCount] = inOutCount[1];
      dashboardContent[Strings.approve] = inOutCount[2];
      dashboardContent[Strings.totalApproved] = inOutCount[3];
    } catch (ex) {
      dashboardContent[Strings.punchInCount] = 0;
      dashboardContent[Strings.punchOutCount] = 0;
      dashboardContent[Strings.approve] = 0;
      dashboardContent[Strings.totalApproved] = 0;
      inOutCount.add(1);
      logErrorInFile(ex.toString());
      Common.toast(ex.toString());
      Future.error(ex);
    }
  }

  updateSyncSuccessfully() async {
    try {
      String date = await getCurrentDate("yyyy-MM-dd");
      String query = "update tbl_attendance set isSync=1 where c_date='$date'";
      int numberOfChanges = await _database.rawUpdate(query);
      print("updateSyncSuccessfully:numberOfChanges=$numberOfChanges");
    } on Exception catch (ex) {
      print("database :DeHelper:updateSyncSuccessfully=${ex.toString()}");
    }
  }

  Future<void> getPunchInAndPunchOutCount(
      ReportController reportController) async {
    try {
      int inCount = 0, outCont = 0, approve = 0, todayApprove = 0;
      await reportController.getAttendanceData();
      if (reportController.attendanceData.value != null) {
        if (reportController.attendanceData.value.data.inData.length > 0) {
          reportController.attendanceData.value.data.inData.forEach((element) {
            if (element.time != null) {
              inCount = inCount + 1;
            }
          });
        } else {
          inCount = 0;
        }
        if (reportController.attendanceData.value.data.outData.length > 0) {
          reportController.attendanceData.value.data.outData.forEach((element) {
            if (element.time != null) {
              outCont = outCont + 1;
            }
          });
        } else {
          outCont = 0;
        }

        await reportController.getAttendanceDataModelisTodayApproved(
            isNotApproved: true);
        if (reportController.attendancesDataModel.value != null) {
          if (reportController.attendancesDataModel.value.data.length > 0) {
            approve = reportController.attendancesDataModel.value.data.length;
          } else {
            approve = 0;
          }
        }

        await reportController.getAttendanceDataModelisTodayApproved(
            isTodayApproved: true);

        if (reportController.attendancesDataModel.value != null) {
          if (reportController.attendancesDataModel.value.data.length > 0) {
            todayApprove =
                reportController.attendancesDataModel.value.data.length;
          } else {
            todayApprove = 0;
          }
        }

        this.inOutCount.value = [inCount, outCont, approve, todayApprove];
      }
    } catch (ex) {
      logErrorInFile(ex.toString());
    }
  }

  Future<String> getCurrentDate(String format,
      {String time, int inOut = 0, int empId}) async {
    try {
      DateFormat dt = DateFormat(format);
      if (inOut == 1) {
        return await getAllLastInDateTime(empId);
      } else {
        var dateTimeString = await getTime();
        var dateTime;

        if (dateTimeString != null) {
          dateTime = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(dateTimeString);
        } else {
          dateTime = DateTime.now();
        }

        dateTime = dt.format(dateTime);
        return dateTime;
      }
    } catch (ex) {
      return "";
    }
  }

  Future<String> getTime() async {
    try {
      var res = await http
          .get(Uri.parse('http://worldtimeapi.org/api/timezone/Asia/Kolkata'));
      if (res.statusCode == 200) {
        dynamic dateTime = jsonDecode(res.body);
        return dateTime['datetime'].toString().split(".")[0];
      }
    } catch (ex) {
      return null;
    }
  }

  Future<String> getAllLastInDateTime(int empId) async {
    try {
      _database = await openAppDatabase();
      String query =
          "SELECT max(c_date) as max_date  FROM $tbl_attendance where emp_id=$empId and OutTime IS NULL";
      return await _database.transaction((txn) async {
        var result = await txn.rawQuery(query);
        String lastDate = result.first['max_date'];
        return lastDate;
      });
    } on Exception {}
  }

  insertDataIntoBackupTable(List<Map<String, dynamic>> records) async {
    try {
      _database = await openAppDatabase();
      if (records.isNotEmpty) {
        await _database.transaction((txn) async {
          records.forEach((element) async {
            await txn.insert(tbl_attendance_backup, element);
          });
        });
      }
    } on DatabaseException catch (ex) {
      if (kDebugMode) {
        log("DashboardController-insertIntoDataBackupTable:${ex.toString()}");
      }
    }
  }

  Future<void> clearAttendanceData() async {
    try {
      _database = await openAppDatabase();
      _database.transaction((txn) async {
        DateTime dayBeforeOneDay = DateTime.now();
        String dateString =
            DateTimeFormatter.displayYYYYMMDD.format(dayBeforeOneDay);
        await txn.delete(tbl_attendance,
            where: "c_date < ? and isSync=?",
            whereArgs: [dateString,1]).then((value) => null, onError: (error) {
          if (kDebugMode) {
            print(error.toString());
          }
        });
      });
    } on DatabaseException catch (ex) {
      if (kDebugMode) {
        print("dashboardController-clearAttendanceData=${ex.toString()}");
      }
    }
  }

// await reportController.getAttendanceData(isNotApproved: true);
// if (reportController.attendanceData.value != null) {
//   if (reportController.attendanceData.value.data.inData.length > 0) {
//     approve = reportController.attendanceData.value.data.inData.length;
//   } else {
//     approve = 0;
//   }
// }

// insertIntoLocation(String mLocation){
//  try {
//    String cDate;
//    String dateTime;
//    String location;
//    DataBaseService _dbServide = DataBaseService();
//    cDate =   getCurrentDate("yyyy-MM-dd");
//    dateTime = getCurrentDate("HH:mm:ss");
//    location = mLocation;
//    _dbServide.saveLocation(location, cDate+" "+dateTime);
//
//  }catch(ex){
//    logErrorInFile(ex.toString());
//   print("error="+ex.toString());
//  }
// }

// Future<void> getPunchInAndPunchOutCount(ReportController reportController) async{
//    try{
//
//       int inCount=0,outCont=0,approve=0,todayApprove=0;
//        await reportController.getAttendanceData();
//         if(reportController.attendanceData.value != null) {
//           if (reportController.attendanceData.value.data.length > 0) {
//
//              reportController.attendanceData.value.data.forEach((element) {
//                if(element.inTime != null){
//                  inCount = inCount+1;
//                }
//                if(element.outTime != null){
//                  outCont = outCont+1;
//                }
//             });
//
//              await reportController.getAttendanceData(isNotApproved: true);
//
//              if(reportController.attendanceData.value != null) {
//                 if(reportController.attendanceData.value.data.length > 0) {
//                   approve = reportController.attendanceData.value.data.length;
//                 }
//              }
//
//              await reportController.getAttendanceData(isTodayApproved: true);
//
//              if(reportController.attendanceData.value != null) {
//                if(reportController.attendanceData.value.data.length > 0) {
//                  todayApprove = reportController.attendanceData.value.data.length;
//                }
//              }
//
//
//               this.inOutCount.value = [inCount, outCont,approve,todayApprove];
//           }
//           else{
//           }
//         }
//
//
//
//
//    }catch(ex){
//      logErrorInFile(ex.toString());
//
//    }
// }

//  String db = "geo_attendance.db";
//  String tbl_attendance = "tbl_attendance";
//  String tbl_trancking  = "tbl_tracking_records";
//  String createAttendanceTable = "CREATE TABLE tbl_attendance(id integer PRIMARY KEY AUTOINCREMENT,emp_id integer,c_date TEXT,inTime TEXT,OutTime TEXT,inLocation TEXT,outLocation TEXT,in_image_path TEXT,out_image_path TEXT,acceptance integer default 1,isSync integer default 0,userName VARCHAR(255) default null)";
//  String createTrackingRecords = "CREATE TABLE tbl_tracking_records(id integer PRIMARY KEY AUTOINCREMENT,emp_id integer,c_date TEXT,dateTime TEXT,Location TEXT)";
//  Database _database;
//
//  final inOutCount = [].obs;
//  final dashboardContent = {}.obs;
//
//
//  @override
//  void onInit() async{
//   _database = await openAppDatabase();
//  }
//
//  Future<Database> openAppDatabase() async {
//      final database = await openDatabase(
//        p.join(await getDbPath(), db),
//        onCreate: (db, version) {
//         db.execute(createAttendanceTable);
//         db.execute(createTrackingRecords);
//        },
//        onUpgrade: (db, oldVersion, newversion) {
//          if(oldVersion <= 3){
//            db.execute("ALTER TABLE $tbl_attendance ADD COLUMN isSync integer default 0");
//            db.execute("ALTER TABLE $tbl_attendance ADD COLUMN userName VARCHAR(255) default null");
//          }
//        },
//        version: 4,
//      );
//      return database;
//
//  }
//  Future<void> getDashboardContain() async{
//    try {
//       final reportController = Get.put(ReportController(false));
//       await getPunchInAndPunchOutCount(reportController);
//       dashboardContent[Strings.punchInCount] = inOutCount[0];
//       dashboardContent[Strings.punchOutCount] = inOutCount[1];
//       dashboardContent[Strings.approve] = inOutCount[2];
//       dashboardContent[Strings.totalApproved] = inOutCount[3];
//    }catch(ex){
//      logErrorInFile(ex.toString());
//      rethrow;
//    }
//  }
//
//  getDbPath() async {
//    String path;
//    path = await getDatabasesPath();
//    return path;
//  }
//
//  insertAttendanceRecords(String date) async{
//    ReportController reportController = Get.put(ReportController(true));
//     await reportController.getAttendanceData(tDate: DateFormat("dd-MM-yyyy")
//            .format(DateTime.now()),fDate: DateFormat("dd-MM-yyyy")
//            .format(DateTime.now())
//           );
//    _database = await openAppDatabase();
//      List<Data> list =  reportController.attendanceData.value.data;
//      List<Map<String,dynamic>> mapList=  list.map((value)=>value.toJson()).toList();
//    for(int i=0;i<mapList.length;i++) {
//      await _database.transaction((txn) async {
//            txn.insert(tbl_attendance, mapList[i]);
//      });
//    }
//  }
//
//
//  insertAttendance(Map<String,dynamic> record,int flag,int empId) async{
//    try{
//
//      var alreadyPunch;
//      alreadyPunch = await getIsPunched(empId);
//      alreadyPunch = alreadyPunch['flag'];
//      if(alreadyPunch == 0) {
//        await _database.transaction((txn) async {
//                return await txn.insert(tbl_attendance, record).then((value){
//                  Common.toast("$punch_in_successfully on Date=${DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now())}");
//            },onError: (error){
//                  print(error.toString());
//                });
//        });
//       }
//      else{
//        if(alreadyPunch == 1) {
//              await _database.transaction((txn) async {
//                      return await txn.update(
//                            tbl_attendance, record, where: "c_date=? and emp_id=?",
//                            whereArgs: [record['c_date'],record['emp_id']]
//                    );
//                });
//           Common.toast("$punch_out_successfully on Date=${DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now())}");
//        }
//      }
//
//    }catch(ex){
//      logErrorInFile(ex.toString());
//      log("Dbheloper:${ex.toString()}");
//    }
//  }
//
//  getIsPunched(int empId) async{
//    try {
//      Map<String, dynamic> flag;
//      Map<String, dynamic> out = Map();
//
//      _database = await openAppDatabase();
//
//      String query = "SELECT * FROM $tbl_attendance where c_date='${getCurrentDate(
//          "dd-MM-yyyy")}' and emp_id=$empId";
//
//       flag = await _database.transaction((txn) async {
//
//        var result = await txn.rawQuery(query);
//
//        if (result.length > 0) {
//
//          if (result[0]["OutTime"] == null) {
//            out["flag"] = 1;
//            out["time"] = result[0]["inTime"];
//            return out;
//          }
//          else {
//            out["flag"] = 2;
//            out["inTime"] =
//            result[0]["inTime"] == null ? "" : result[0]["inTime"];
//            out["time"] =
//            result[0]["OutTime"] == null ? "" : result[0]["OutTime"];
//            return out;
//          }
//        }
//        else {
//          out["flag"] = 0;
//          out["time"] = "";
//          return out;
//        }
//      });
//
//      return flag;
//    }catch(ex){
//      logErrorInFile(ex.toString());
//    }
//  }
//
// Future<Map<String,dynamic>> getTimes(int empId) async{
//    try{
//      _database = await openAppDatabase();
//      Map<String,dynamic> record;
//      String query = "SELECT inTime,OutTime FROM $tbl_attendance where c_date='${getCurrentDate("dd-MM-yyyy")}' and emp_id=${empId}";
//      record = await _database.transaction((txn)async{
//               Map<String,dynamic> row;
//               var result = await txn.rawQuery(query);
//               if(result != null) {
//                row = Map();
//                row["inTime"] = result[0]["inTime"];
//                row["OutTime"] = result[0]["OutTime"];
//              }
//              return row;
//       });
//      return record;
//     }catch(ex){
//      logErrorInFile(ex.toString());
//        log(ex.toString());
//    }
//  }
//
//
//  Future<List<Map<String,dynamic>>> getAllRecords({String fDate,String tDate}) async{
//    try{
//          List<Map<String,dynamic>> records;
//          String query;
//          _database = await openAppDatabase();
//          if(fDate == null && tDate == null)
//          query = "SELECT * FROM "+tbl_attendance+" where c_date != '${getCurrentDate("dd-MM-yyyy")}' order by c_date desc limit 6 ";
//          else
//           query = "SELECT * FROM "+tbl_attendance+" where c_date between '$fDate' and '$tDate' order by c_date desc";
//           records = await _database.transaction((txn){
//           return txn.rawQuery(query);
//         });
//         return records;
//     }catch(ex){
//      logErrorInFile(ex.toString());
//         return [];
//    }
//  }
//
//  Future<List<Map<String,dynamic>>> getAllAttendanceRecordsString() async{
//    try{
//      List<Map<String,dynamic>> records=[];
//      _database = await openAppDatabase();
//
//        //emp_id integer,c_date TEXT,inTime TEXT,OutTime TEXT,inLocation TEXT,outLocation TEXT,in_image_path TEXT,out_image_path TEXT,acceptance integer
//        String query = "SELECT emp_id,c_date,inTime,OutTime,inLocation,outLocation,in_image_path,out_image_path,acceptance,userName FROM "+tbl_attendance+" where c_date = '${getCurrentDate("dd-MM-yyyy")}' order by c_date desc";
//        records = await _database.transaction((txn) async{
//            List<Map<String,dynamic>> response = await txn.rawQuery(query);
//            return response;
//       });
//       return records;
//    } catch(ex){
//      logErrorInFile(ex.toString());
//      return [];
//    }
//  }
//
//  Future<String> getAllLocationRecordsString() async{
//    try{
//       String records;
//       _database = await openAppDatabase();
//       String query = "SELECT * FROM "+tbl_trancking+" where c_date = ${getCurrentDate("dd-MM-yyyy")} order by c_date desc";
//       records = await _database.transaction((txn) async{
//         var response = await txn.rawQuery(query);
//            return json.encode(response);
//      });
//      return records;
//    } catch(ex){
//      logErrorInFile(ex.toString());
//      return json.encode([]);
//    }
//  }
//
//  String getCurrentDate(String format){
//    DateFormat dt = DateFormat(format);
//    return dt.format(DateTime.now());
//  }
//
//  insertIntoLocation(String mlocation){
//   try {
//     String cDate;
//     String dateTime;
//     String location;
//     DataBaseService _dbServide = DataBaseService();
//     cDate =   getCurrentDate("dd-MM-yyyy");
//     dateTime = getCurrentDate("HH:mm:ss");
//     location = mlocation;
//     _dbServide.saveLocation(location, cDate+" "+dateTime);
//
//   }catch(ex){
//     logErrorInFile(ex.toString());
//    print("error="+ex.toString());
//   }
//  }
//
//  Future<void> getPunchInAndPunchOutCount(ReportController reportController) async{
//     try{
//
//        int inCount=0,outCont=0,approve=0,todayApprove=0;
//         await reportController.getAttendanceData();
//          if(reportController.attendanceData.value != null) {
//            if (reportController.attendanceData.value.data.length > 0) {
//
//               reportController.attendanceData.value.data.forEach((element) {
//                 if(element.inTime != null){
//                   inCount = inCount+1;
//                 }
//                 if(element.outTime != null){
//                   outCont = outCont+1;
//                 }
//              });
//
//               await reportController.getAttendanceData(isNotApproved: true);
//
//               if(reportController.attendanceData.value != null) {
//                  if(reportController.attendanceData.value.data.length > 0) {
//                    approve = reportController.attendanceData.value.data.length;
//                  }
//               }
//
//               await reportController.getAttendanceData(isTodayApproved: true);
//
//               if(reportController.attendanceData.value != null) {
//                 if(reportController.attendanceData.value.data.length > 0) {
//                   todayApprove = reportController.attendanceData.value.data.length;
//                 }
//               }
//
//
//                this.inOutCount.value = [inCount, outCont,approve,todayApprove];
//            }
//            else{
//            }
//          }
//
//
//
//
//     }catch(ex){
//       logErrorInFile(ex.toString());
//
//     }
//  }

//   await reportController.getAttendanceData(isNotApproved: true);
//   if (reportController.attendanceData.value != null) {
//     if (reportController.attendanceData.value.data.length > 0) {
//       approve = reportController.attendanceData.value.data.length;
//     } else {
//       approve = 0;
//     }
//   }
//
//   await reportController.getAttendanceData(isTodayApproved: true);
//
//   if (reportController.attendanceData.value != null) {
//     if (reportController.attendanceData.value.data.length > 0) {
//       todayApprove = reportController.attendanceData.value.data.length;
//     } else {
//       todayApprove = 0;
//     }
// }

}
