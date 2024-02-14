import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:geo_attendance_system/database/DbHelper.dart';
import 'package:get/get.dart';

class FetchDataService extends GetxService {
  final _connectivity = Connectivity();
  final dbHelper = Get.put(DbHelper());
  Timer _timer;
  bool isInternetF = false;

  @override
  void onInit() {
    checkInternet();
    super.onInit();
  }

  void checkInternet() async {
    // setBackgroundService();
    final _connectivityResult = await (_connectivity.checkConnectivity());
    if (_connectivityResult != ConnectivityResult.none) {
      isInternetF = true;
      //print(Strings.noInternetMsg);
    }
    _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (ConnectivityResult.none == result) {
        isInternetF = true;
        //  log(Strings.noInternetMsg);
      } else {
        print("restart $isInternetF");
        if (isInternetF) {
          isInternetF = false;
          //TODO: uncomment before build
          runProgram();
        }
      }
    });
  }

  void runProgram() {
    // _timer = Timer.periodic(Duration(minutes: 30), (timer) async {
    //   WidgetsFlutterBinding.ensureInitialized();
    //   // TODO: check 5 min
    //   final _connectivityResult = await (_connectivity.checkConnectivity());
    //   if (_connectivityResult != ConnectivityResult.none) {
    //     Map<String,dynamic> body = Map();
    //     body['data'] =  await dbHelper.getAllAttendanceRecordsString();
    //   //  saveAttendanceOnServer(body);
    //     log(Strings.noInternetMsg);
    //     //TODO: is available internet
    //   } else {
    //        log(Strings.noInternetMsg);
    //   }
    // });
  }

  @override
  void onClose() {
    // TODO: implement onClose
    _timer.cancel();
    super.onClose();
  }

// void setBackgroundService() {
//    service = FlutterBackgroundService();
//   service.onDataReceived.listen((event) {
//     if (event["action"] == "setAsForeground") {
//       service.setForegroundMode(true);
//       return;
//     }
//     if (event["action"] == "setAsBackground") {
//       service.setForegroundMode(false);
//     }
//     if (event["action"] == "stopService") {
//       service.stopBackgroundService();
//     }
//   });
//   service.setForegroundMode(true);
// }
}
