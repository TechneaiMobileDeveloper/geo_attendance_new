// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_attendance_system/controllers/attendance_controller.dart';

import 'package:geo_attendance_system/main.dart';
import 'package:geo_attendance_system/ui/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(SplashScreen());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
  group("API TESTING", (){
     test("insertAttendance", () async{
        AttendanceController controller  = AttendanceController();
        Map<String, dynamic> body = {"faceData":[{"emp_id":12,"date":"2023-01-06","time":"09:57:48","type":"IN","location":"{\"longitude\":73.8657111,"
        "\"latitude\":18.5195044,\"timestamp\":1672979270058,\"accuracy\":16.523000717163086,""\"altitude\":486.79998779296875,\"floor\":null,\"heading\":0.0,"
        "\"speed\":0.0,\"speed_accuracy\":0.0,\"is_mocked\":false}","image_path":"http://13.126.136.155/techneai-dummy/storage/app/attendance/2023/Jan/"
        "2023-01-06/12/heuDNnI6xC42F2Ior5lFpnsy36AUisAmvLomcVpI.jpeg","acceptance":1},
        {"emp_id":12,"date":"2023-01-06","time":"09:58:34","type":"OUT","location":"{\"longitude\":73.8657101,\"latitude\":18.5194994,\"timestamp\":1672979315537,"
        "\"accuracy\":13.984999656677246,\"altitude\":486.6999816894531,\"floor\":null,""\"heading\":0.0,\"speed\":0.0,\"speed_accuracy\":0.0,\"is_mocked\":false}",
        "image_path":"http://13.126.136.155/techneai-dummy/storage/app/attendance/2023/Jan/2023-01-06/12/0mFz9beD635jUaLg9hfF7LdDOkvhNjzvImNjXXYy.jpeg","acceptance":1}]
     };

    dynamic response =  await  controller.saveAttendanceOnServer(body);
   // print(json.encode(response));


     });

  });

}
