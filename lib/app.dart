import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/res/theme_data.dart';
import 'package:geo_attendance_system/ui/splash_screen.dart';
import 'package:get/get.dart';

class NavKey {
  static final navKey = GlobalKey<NavigatorState>();
}

class App {
  static App instance = App();

  bool _devMode = false;

  bool get devMode => _devMode;

  startApp({
    @required bool devMode,
  }) async {
    _devMode = devMode;
    WidgetsFlutterBinding.ensureInitialized();
    //await Firebase.initializeApp();
    runApp(ConnectivityAppWrapper(
      app: GetMaterialApp(
        debugShowCheckedModeBanner: _devMode ? true : false,
        navigatorKey: NavKey.navKey,
        home: SplashScreen(),
        theme: appTheme,
      ),
    ));
  }
}
//
// //apply this class on home: attribute at MaterialApp()
// class MyFileList extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _MyFileList();
//   }
// }
//
// class _MyFileList extends State<MyFileList> {
//   var files;
//   DummyController _dummyController = Get.put(DummyController());
//
//   @override
//   void initState() {
//     _listenForPermissionStatus();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: Text("File/Folder list from SD Card"),
//           backgroundColor: Colors.redAccent),
//       body: _dummyController.listImage == null
//           ? Text("Searching Files")
//           : Obx(
//               () => GridView.count(
//                 crossAxisCount: 5,
//                 mainAxisSpacing: 5,
//                 crossAxisSpacing: 5,
//                 children: List.generate(
//                   _dummyController.listImage?.length ?? 0,
//                   (index) => Image.file(
//                     _dummyController.listImage[index],
//                     cacheWidth: 400,
//                     cacheHeight: 400,
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
//
//   void _listenForPermissionStatus() async {
//     bool _permissionStatus = false;
//     final status = await Permission.storage.request().isGranted;
//     // setState() triggers build again
//     setState(() => _permissionStatus = status);
//   }
// }
//
// class DummyController extends GetxController {
//   final listImage = List<dynamic>.empty(growable: true).obs;
//
//   @override
//   void onInit() {
//     _fetchFiles();
//     super.onInit();
//   }
//
//   _fetchFiles() async {
//     Directory dir = Directory("storage/emulated/0/compressed/compressed");
//     dir.list().forEach((element) {
//       if (element.path.contains("JPG")) listImage.add(element);
//     });
//     update();
//   }
// }
