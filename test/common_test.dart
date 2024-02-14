import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:geo_attendance_system/network/api_client.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/ui/pages/test_controller.dart';
import 'package:get/get.dart';

main() {
  test("clear faces", () async {
    String url = AppUrl.urlFaceBase() + "AddUserFace.php";
    APIClient apiClient = APIClient();
    Map<String, dynamic> body = {};
    body['faceData'] = json.encode({});
    final response = await apiClient.post(url, data: body);
  });

  test("isGreaterThanTen", () {
    final controller = Get.put(TestController());
    //double total =  controller.testCalculation(5, 6);
    // expect(total, 11);
  });
}
