import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geo_attendance_system/controllers/setting_controller.dart';
import 'package:geo_attendance_system/service/facenet.service.dart';
import 'package:geo_attendance_system/utils/enums.dart';
import 'package:geo_attendance_system/utils/methods.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io' as Io;
import 'package:geo_attendance_system/database/DbHelper.dart';
import 'package:geo_attendance_system/db/database.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/ui/constants/strings.dart';
import 'package:geo_attendance_system/utils/assets.dart';
import 'package:geo_attendance_system/utils/auth/auth_manager.dart';
import 'package:http_parser/http_parser.dart';
import 'package:geo_attendance_system/utils/common.dart';
import 'package:geo_attendance_system/utils/picker_handler.dart';

//import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../res/strings.dart';

class DashboardController extends GetxController implements PickerListener {
  final _captureImage = File("").obs;
  final mProgress = 0.0.obs;
  final totalTime = "00:00".obs;
  PickerHandler _pickerHandler;
  final manual = true.obs;
  final checkIn = "".obs;
  final checkOut = "".obs;
  final mtime = "".obs;
  final auto = false.obs;
  bool isMultiUser;
  final outClicked = false.obs;
  final inClicked = false.obs;
  final conflict = false.obs;
  final isLoadedModal = true.obs;
  final listPosition = List<Position>.empty(growable: true).obs;
  final verticalGroupValue = "Manual".obs;

  // 2 means no error
  final errorEmpId = 2.obs;

  TextEditingController empIdController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  DataBaseService dataBaseService;
  DbHelper dbHelper;
  final flag = 0.obs;
  final empId = 0.obs;
  final isIn = 0.obs;

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> dashboardItems = [
    {'name': "My Goals", 'logo': Assets.mygoal}
  ];
  bool visibleList = false;
  bool isDemo = false;
  Map<String, dynamic> locations;
  int timeIntValue = 1;

  final currentDateTime = DateTime.now().obs;

  final isTappedMenu = true.obs;

  DashboardController(bool isUser) {
    isMultiUser = isUser;
  }

  @override
  void onInit() async {
    dataBaseService = DataBaseService();
    dbHelper = Get.put(DbHelper());
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Get.put(preferences);
    //   this.currentDateTime.value = await getTime();
    if (!isMultiUser) {
      empId.value = AuthManager().getLoginData().data.id;
    }
    super.onInit();
  }

  getPunchTimoutDetails() async {
    Map<String, dynamic> out = await dbHelper.getIsPunched(empId.value);
    if (out['flag'] == 1) {
      checkIn.value = out['time'];
    } else if (out['flag'] == 2) {
      checkOut.value = out['time'];
      checkIn.value = out['inTime'];
    }
    flag.value = out['flag'];
  }

  setPunchIN() async {
    Map<String, dynamic> result = await dbHelper.getIsPunched(empId.value);
    this.isIn.value = result['flag'];
  }

  takePhoto(int flag) async {
    this.flag.value = flag;
    var result = await dbHelper.getIsPunched(412);
    result = result['flag'];
    if (result == 0 || result == 1) {
      if (this.flag.value == 0 && result == 1) {
        Common.toast(alerady_punched_in);
      } else if ((result == 0 && this.flag.value == 0) || result == 1) {
        _pickerHandler.pickImageFromCamera();
      }
    } else if (result == 2) {
      Common.toast(already_end_punch_today);
    }
  }

  @override
  pickerFile(File _file) {
    _captureImage.value = _file;
    saveFile(_file, this.flag.value);
  }

  void saveFile(File mFile, int flag,
      {int empId = 0,
      int acceptance = 1,
      String userName = '',
      int InOut = 0}) async {
    try {
      // String path, month, date, monthDir, dateDir;
      //File file;
      // DateFormat monthFormat = DateFormat.MMM();
      // DateFormat dateFormat = DateFormat("dd-MM-yyyy");
      // Directory directory = await getExternalStorageDirectory();
      // path = directory.path;
      // month = monthFormat.format(DateTime.now());
      // date = dateFormat.format(DateTime.now());
      // monthDir = await getDirectory(path, month);
      // dateDir = await getDirectory(monthDir, date);
      // file = File(dateDir + "/" + "${empId}_t$flag.jpeg");
      // if (!file.existsSync()) {
      //   await file.create();
      //   await file.writeAsBytes(mFile.readAsBytesSync());
      // } else {
      //   await file.writeAsBytes(mFile.readAsBytesSync());
      // }

      this.flag.value = flag;

      final settingController = Get.find<SettingController>();

      String url = await getIpAddress(settingController: settingController) +
          AppUrl.uploadImage;

      // uploading image
      if (acceptance == 0) {
        uploadImage(mFile.path, url, empId).then((value) async {
          String filePath = "";
          if (value != null) {
            dynamic body = json.decode(value.body);
            if (value.statusCode == 200) {
              if (body['success']) {
                filePath = body['file'];
                saveAttendanceDetails(this.flag.value, mFile.path, empId,
                    acceptance, userName, filePath,
                    Inout: InOut);
              } else {
                saveAndInsert(mFile, empId, acceptance, userName, InOut);
              }
            } else {
              saveAndInsert(mFile, empId, acceptance, userName, InOut);
            }
          } else {
            saveAndInsert(mFile, empId, acceptance, userName, InOut);
            Common.toast("Value Null");
          }
        }, onError: (error) {
          saveAndInsert(mFile, empId, acceptance, userName, InOut);
        });
      } else {
        saveAndInsert(mFile, empId, acceptance, userName, InOut);
      }
    } catch (ex) {
      Get.defaultDialog(title: "Error", middleText: ex.toString());
    }
  }

  void saveAndInsert(
      File file, int empId, int acceptance, String userName, int InOut) async {
    try {
      String filePath;
      final bytes = await Io.File(file.path).readAsBytes();
      String img64 = base64Encode(bytes);
      filePath = img64;
      saveAttendanceDetails(
          this.flag.value, file.path, empId, acceptance, userName, filePath,
          Inout: InOut);
    } on Exception catch (ex) {
      Common.toast("Line-197:${ex.toString()}");
      print("${ex.toString()}");
    }
  }

  List<Position> getPositionWithFilter(List<Position> mPositions, {int time}) {
    int difference, flag = 1;

    for (int i = 0; i < mPositions.length; i++) {
      for (int j = i + 1; j < mPositions.length; j++) {
        difference = getLastSyncTimeDifference(
            mPositions[i].timestamp, mPositions[j].timestamp);

        if (difference >= (time == null ? 30 : time)) {
          mPositions[i + 1] = mPositions[j];
          flag = flag + 1;
          break;
        } else {
          mPositions.removeAt(j);
        }
      }
    }
    if (mPositions.length > 0) {
      return mPositions.sublist(0, flag);
    } else
      return mPositions;
  }

  int getLastSyncTimeDifference(DateTime date1, DateTime date2) {
    return date2.difference(date1).inMinutes;
  }

  Future<String> getDirectory(String root, String path) async {
    Directory directory = Directory(root + "/" + path);
    bool isExits = await directory.exists();
    if (!isExits) {
      directory.create(recursive: false);
    }
    return directory.path;
  }

  Future<void> moveAttendanceBackup() async {
    try {
      dbHelper = Get.put(DbHelper());
      List<Map<String, dynamic>> records =
          await dbHelper.getAllAttendanceRecordsString(forBackup: true);
      await dbHelper.insertDataIntoBackupTable(records);
      await dbHelper.clearAttendanceData();
    } catch (ex) {
      if (kDebugMode) {
        print("moveAttendanceBackup-${ex.toString()}");
      }
    }
  }

  void saveAttendanceDetails(int value, String path, int empId, int acceptance,
      String userName, String filePath,
      {int Inout = 0}) async {
    try {
      dbHelper = Get.put(DbHelper());
      String currentDate = await getCurrentDate("yyyy-MM-dd");
      String currentTime = await getCurrentDate("HH:mm:ss");
      Map<String, dynamic> row = Map();
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (position != null) {
          if (position.latitude != null && position.longitude != null) {
            row['lat'] = position.latitude.toString();
            row['lon'] = position.longitude.toString();
            row['location'] = jsonEncode(position.toJson());
          } else {
            row['lat'] = "";
            row['lon'] = "";
          }
        } else {
          row['lat'] = "";
          row['lon'] = "";
        }
      } on FormatException catch (ex) {
        row['lat'] = "";
        row['lon'] = "";
        Common.toast(ex.toString());
      } catch (ex) {
        row['lat'] = "";
        row['lon'] = "";
        Common.toast(ex.toString());
      }
      row['emp_id'] = empId;
      row['userName'] = userName;
      row['c_date'] = currentDate;
      row['time'] = currentTime;

      if (Inout == 0) {
        row['type'] = "IN";
      } else {
        row['type'] = "OUT";
      }
      row['image_path'] = filePath;
      row['acceptance'] = acceptance;

      var result = dbHelper.insertAttendance(
          row, this.flag.value, empId, currentTime,
          InOut: Inout);
      if (result == 1) {
        print("alrday..2");
        Common.toast(Strings.alreadyPunchedIn);
      }
    } catch (ex) {
      Common.toast(ex.toString());
    }
  }

  Future<String> getCurrentDate(String format) async {
    DateFormat dt = DateFormat(format);
    try {
      var dateTimeString = await getTime();
      var dateTime;
      if (dateTimeString != null) {
        dateTime = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(dateTimeString);
      } else {
        dateTime = DateTime.now();
      }
      return dt.format(dateTime);
    } catch (ex) {
      return dt.format(DateTime.now());
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

  getProgress(int empId) async {
    try {
      String inTime, outTime;
      Map<String, dynamic> map = await dbHelper.getTimes(empId);

      if (map != null) {
        if (map['OutTime'] == null) {
          outTime = await getCurrentDate("HH:mm:ss");
        } else {
          outTime = map['OutTime'];
        }
        inTime = map["inTime"];
        if (getTimeDifference(outTime, inTime) <= 1)
          this.mProgress.value = getTimeDifference(outTime, inTime);
      } else {
        this.mProgress.value = 0;
      }
    } catch (ex) {}
  }

  double getTimeDifference(String outTime, String inTime) {
    DateFormat _format = DateFormat("HH:mm:ss");
    int timeDifference;
    DateTime dtOutTime, dtInTime;
    try {
      log("inTime=$inTime,outTime=$outTime");
      int hours, minutes;

      dtOutTime = _format.parse(outTime);
      dtInTime = _format.parse(inTime);

      timeDifference = dtOutTime.difference(dtInTime).inSeconds;

      log("timeDifference=$timeDifference");

      //  seconds = timeDifference % 60;
      minutes = timeDifference ~/ 60;
      hours = timeDifference ~/ 3600;

      log("hours=$hours:minutes=$minutes");

      totalTime.value = _printDuration(dtOutTime.difference(dtInTime));

      return timeDifference / 28800;
    } catch (ex) {
      return 0;
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String getTimeDifferenceString(String outTime, String inTime) {
    DateFormat _format = DateFormat("HH:mm:ss");
    int timeDifference;
    DateTime dtOutTime, dtInTime;
    try {
      log("inTime=$inTime,outTime=$outTime");
      int hours, minutes;
      if (outTime != null && inTime != null) {
        dtOutTime = _format.parse(outTime);
        dtInTime = _format.parse(inTime);
        timeDifference = dtOutTime.difference(dtInTime).inMinutes;
        log("timeDifference=$timeDifference");
        hours = timeDifference ~/ 60;
        minutes = (timeDifference) % 60;
        log("hours=$hours:minutes=$minutes");
        return "${hours < 10 ? "0${hours.isEqual(0) ? '0' : hours}" : hours}:${minutes < 10 ? "0${minutes.isEqual(0) ? '0' : minutes}" : minutes}";
      } else {
        return "00:00";
      }
    } catch (ex) {
      return "";
    }
  }

  void startMinuteClock(int empId) {
    final oneMinute = Duration(seconds: 1);
    Timer.periodic(oneMinute, (Timer t) {
      getProgress(empId);
    });
  }

  String getDeviceType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 600 ? 'phone' : 'tablet';
  }

  // getLocationString(Position position) async {
  //   final coordinates = new Coordinates(position.latitude, position.longitude);
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   var first = addresses.first;
  //   return first.addressLine;
  // }

  void onAutoChecked(bool val) {
    if (val) {
      this.manual.value = false;
    }
    this.auto.value = val;
  }

  readAllLocationsAndFilter({int time}) async {
    Map<String, dynamic> locations;
    List<Position> positions = [];
    dataBaseService.loadLocations().then((value) {
      locations = dataBaseService.location;
      print("totalLocations=${locations.values.length}");
      positions = locations.values
          .map((e) => Position.fromMap(json.decode(e)))
          .toList();
      positions = time == null
          ? getPositionWithFilter(positions)
          : getPositionWithFilter(positions, time: time);
      getProgress(AuthManager().getLoginData().data.id);
      listPosition.value = positions;
      print(listPosition.length.toString() + "powsiwwwwwwww");
      //update();
    });
  }

  void onManualChecked(bool val) {
    if (val) {
      this.auto.value = false;
      this.manual.value = true;
    }
    this.manual.value = val;
  }

  int getEmployeeId() {
    return empId.value;
  }

  Future<http.Response> uploadImage(filepath, url, dynamic empId) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', filepath,
          contentType: MediaType('image', 'jpeg')));
      request.fields['emp_id'] = empId.toString();
      request.persistentConnection = true;
      http.Response response =
          await http.Response.fromStream(await request.send());
      return Future.value(response);
    } on HttpException catch (ex) {
      Future.error(ex);
    } on Exception catch (ex) {
      Future.error(ex);
    }
  }

  Future<void> checkFaceExist(
      String empId, FaceNetService faceNetService) async {
    try {
      List value = [];
      String key;
      String _key = faceNetService.findKey(empId);

      if (_key.isEmpty) {
        Map<String, dynamic> response =
            await dataBaseService.getEmployeeFaceData(empId);
        if (response.isNotEmpty) {
          if (response['success']) {
            key = response['key'];
            value = response['data'];
            dataBaseService.db[key] = value;
          }
        }
      }
    } catch (ex) {
      print(ex.toString());
    }
  }

  Future<int> validateEmpId() async {
    try {
      int result = await dataBaseService.getEmployeeData(empIdController.text);
      return result;
    } catch (ex) {
      print(ex.toString());
      return 0;
    }
  }

  // findIsActiveEmployee
  int findIsActiveEmployee(String empId) {
    try {
      MapEntry mapEntry = dataBaseService.db.entries
          .firstWhere((element) => element.key.split(":")[1] == empId);
      dynamic value = mapEntry.value;
      return value['is_active'] == UserType.active.index ? 2 : 3;
    } catch (ex) {
      return 0;
    }
  }

  void reloadDashboardContain() async {
    isLoadedModal.value = true;
    await dbHelper.getDashboardContain();
    isLoadedModal.value = false;
  }

// void uploadImage(String path) async{
//    try{
//      APIClient apiClient = APIClient();
//      String url = AppUrl.urlFaceBase()+AppUrl.uploadImage;
//      FormData formData = FormData.fromMap({
//        "file":
//        await MultipartFile.fromFile(file.path, filename:fileName),
//      });
//      apiClient.post(url,data: )
//    }catch(ex){
//
//    }
// }

}
