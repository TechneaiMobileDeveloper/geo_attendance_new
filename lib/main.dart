import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/app.dart';
import 'package:geo_attendance_system/controllers/attendance_controller.dart';
import 'package:geo_attendance_system/controllers/dashboard_controller.dart';
import 'package:geo_attendance_system/controllers/user_controller.dart';
import 'package:geo_attendance_system/ui/constants/strings.dart';
import 'package:get/get.dart';

List<CameraDescription> cameras = [];

void printHello() async {
  print("printHello");
  try {} catch (ex) {
    print(ex.toString());
  }
}

//DbHelper _dbService = DbHelper();
final userController = Get.put(UserController());
final dashboardController = Get.put(DashboardController(false));
final attendanceController = Get.put(AttendanceController());
final connectivity = Connectivity();
bool isInternetF = false;
 bool isSyncing = false;

 int totalTick = 0;

void main() async {
  App.instance.startApp(devMode: false);

  if (isMultiuser) {
    WidgetsFlutterBinding.ensureInitialized();
    //await initializeService();
    cameras = await availableCameras();
  }
}

// bool onIosBackground() {
//   WidgetsFlutterBinding.ensureInitialized();
//   print('FLUTTER BACKGROUND FETCH');
//
//   return true;
// }

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//
//   /// OPTIONAL, using custom notification channel id
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'my_foreground', // id
//     'MY FOREGROUND SERVICE', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.low, // importance must be at low or higher level
//   );
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   if (Platform.isIOS) {
//     await flutterLocalNotificationsPlugin.initialize(
//       const InitializationSettings(
//         iOS: DarwinInitializationSettings(),
//       ),
//     );
//   }
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//       notificationChannelId: 'my_foreground',
//       initialNotificationTitle: 'AWESOME SERVICE',
//       initialNotificationContent: 'Initializing',
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(
//       // auto start service
//       autoStart: true,
//
//       // this will be executed when app is in foreground in separated isolate
//       onForeground: onStart,
//
//       // you have to enable background fetch capability on xcode project
//       onBackground: onIosBackground,
//     ),
//   );
//
//   service.startService();
// }
//
// // to ensure this is executed
// // run app from xcode, then from xcode menu, select Simulate Background Fetch
//
// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   await preferences.reload();
//   final log = preferences.getStringList('log') ?? <String>[];
//   log.add(DateTime.now().toIso8601String());
//   await preferences.setStringList('log', log);
//
//   return true;
// }
//
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // Only available for flutter 3.0.0 and later
//   DartPluginRegistrant.ensureInitialized();
//
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   await preferences.setString("hello", "world");
//
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });
//
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }
//
//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
//
//   // bring to foreground
//   Timer.periodic(const Duration(seconds: 1), (timer) async {
//     try {
//       if (service is AndroidServiceInstance) {
//         if (await service.isForegroundService()) {
//           sendAttendanceDataServerCron(timer);
//           fetchDataFromServerCron(timer);
//         }
//       }
//     } on Exception catch (ex) {
//       Common.toast("main.dart:LineNo-172${ex.toString()}");
//       return;
//     }
//   });
// }
//
// void sendAttendanceDataServerCron(Timer timer) async {
//   try {
//     bool isSyncMin = timer.tick % 60 == 0;
//     if ((!isSyncing) && isSyncMin) {
//       isSyncing = true;
//       final _connectivityResult = await (connectivity.checkConnectivity());
//       if (_connectivityResult != ConnectivityResult.none) {
//         Map<String, dynamic> body = Map();
//         var records = await _dbService.getAllAttendanceRecordsString();
//         if (records.length > 0) {
//           body['faceData'] = records;
//           await logSyncDetaInFile("\n${jsonEncode(body)}");
//           dynamic response =
//               await attendanceController.saveAttendanceOnServer(body);
//           if (response['success']) {
//             await _dbService.updateSyncSuccessfully();
//           }
//         } else {
//           log(Strings.noInternetMsg);
//         }
//         isSyncing = false;
//       }
//     }
//   } on DioError catch (ex) {
//     logErrorInFile(ex.toString());
//   } catch (ex) {
//     logErrorInFile(ex.toString());
//   }
// }
//
// void fetchDataFromServerCron(Timer timer) async {
//   bool isFetchData = (timer.tick % ((2 * 60) + 10)) == 0;
//
//   if (isFetchData && (!isSyncing)) {
//     DataBaseService apiService = DataBaseService();
//     Map<String, dynamic> body = {};
//     isSyncing = true;
//
//     body['f_date'] = DateFormat("yyyy-MM-dd").format(DateTime.now());
//     body['t_date'] = DateFormat("yyyy-MM-dd").format(DateTime.now());
//
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     Get.put(sharedPreferences);
//     Get.put(SettingController());
//
//     AttendanceData data = await apiService.getAttendanceData(body);
//
//     if (data != null) {
//       List<InData> inData = data.data.inData;
//       inData.addAll(data.data.outData);
//
//       inData.forEach((element) {
//         int type = 0;
//         Map<String, dynamic> record = element.toJson();
//         record.removeWhere((key, value) {
//           return (key == "created_at" || key == "updated_at");
//         });
//         type = element.type == "IN" ? 0 : 1;
//         _dbService.insertAttendance(record, 0, element.empId, element.time,
//             InOut: type, isServer: true);
//       });
//     }
//     isSyncing = false;
//   }
// }
//
// Future<void> saveLocationOnServer(Map<String, dynamic> body) async {
//   try {
//     String url = AppUrl.urlFaceBase() + AppUrl.saveLocation;
//     APIClient apiClient = APIClient();
//     final response = await apiClient.post(url, data: body);
//     print(response.toString());
//   } catch (ex) {
//     print(ex.toString());
//   }
//}
