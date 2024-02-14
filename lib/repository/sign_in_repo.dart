import 'package:dio/dio.dart' as form;
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/models/login_response.dart';
import 'package:geo_attendance_system/network/api_client.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/utils/common.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

class SignInRepository {
  final APIClient _apiClient = Get.find();
  String deviceId;

  Future<LoginResponse> login(
      {@required String username,
      @required password,
      @required deviceID}) async {
    final url = AppUrl.urlBase() + AppUrl.subDummyPath() + AppUrl.login;

    if (username.toLowerCase() == Strings.admin) {
      deviceId = Strings.deviceId;
    } else {
      deviceId = deviceID;
    }

    Map<String, dynamic> response = await _apiClient.post(
      url,
      data: {APIKeys.username: username, APIKeys.password: password},
    );

    return LoginResponse.fromJson(response);
  }
}
