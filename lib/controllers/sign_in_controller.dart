import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_attendance_system/models/login_response.dart';
import 'package:geo_attendance_system/repository/sign_in_repo.dart';
import 'package:geo_attendance_system/res/api_keys.dart';
import 'package:geo_attendance_system/res/app_constants.dart';
import 'package:geo_attendance_system/res/strings.dart';
import 'package:geo_attendance_system/ui/pages/dashboard.dart';
import 'package:geo_attendance_system/utils/auth/auth_manager.dart';
import 'package:geo_attendance_system/utils/common.dart';
import 'package:geo_attendance_system/utils/widget/loading_dialog.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

//import 'package:get_version/get_version.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../app.dart';

class SignInController extends GetxController {
  SignInRepository _signInRepository = Get.put(SignInRepository());
  TextEditingController usernameTextController;
  TextEditingController passwordTextController;

  bool passwordVisible = false;

  final projectVersion = "".obs;

  void toggleVisible() {
    passwordVisible = !passwordVisible;
    update();
  }

  @override
  void onInit() {
    _versionName();
    usernameTextController =
        TextEditingController(text: App.instance.devMode ? "haridas" : "");
    passwordTextController =
        TextEditingController(text: App.instance.devMode ? "123456" : "");
    super.onInit();
  }

  _versionName() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      projectVersion.value = packageInfo.version;
    } on PlatformException {
      projectVersion.value = 'Failed to get project version.';
    }
  }

  void userLogin() async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    try {
      LoginResponse loginResponse = await _signInRepository.login(
          username: usernameTextController.text,
          password: passwordTextController.text,
          deviceID: await PlatformDeviceId.getDeviceId);
      if (loginResponse.status == Constants.status) {
        Common.toast(loginResponse.message);
        Get.find<AuthManager>().saveLoginData(loginResponse);

        if (loginResponse.data.role == 1)
          Get.offAll(() => DashboardScreen(
                isMultiUser: false,
                isAdmin: false,
              ));
        else
          Get.offAll(() => DashboardScreen(
                isMultiUser: true,
                isAdmin: false,
              ));
      } else {
        Get.back();
        Common.toast(loginResponse.message);
      }
    } on DioError catch (e) {
      Get.back();
      //Get.off(() => DashboardScreen());
      //   Common.toast(e.response.data[APIKeys.msg]);
    } catch (e) {
      Common.toast(Strings.somethingWentWrong);
      log("SignInController : userLogin Error : ${e.runtimeType}");
      Get.back();
    }
  }
}
