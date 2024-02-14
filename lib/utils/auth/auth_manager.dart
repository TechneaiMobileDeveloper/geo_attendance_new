import 'dart:convert';
import 'package:geo_attendance_system/models/login_response.dart';
import 'package:geo_attendance_system/ui/pages/dashboard.dart';
import 'package:geo_attendance_system/ui/pages/sign_in_screen.dart';
import 'package:geo_attendance_system/utils/shared_pref_manager/sp_keys.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  AuthManager();

  bool isUserLoggedIn() {
    return getLoginData() != null;
  }

  void saveLoginData(LoginResponse loginResponse) {
    final SharedPreferences _prefs = Get.find();
    _prefs.setString(
      SPKeys.loginUserData.toString(),
      jsonEncode(loginResponse.toJson()),
    );
  }

  LoginResponse getLoginData() {
    final SharedPreferences _prefs = Get.find();
    String tempStr = _prefs.getString(
      SPKeys.loginUserData.toString(),
    );
    try {
      return LoginResponse.fromJson(jsonDecode(tempStr));
    } catch (e) {
      return null;
    }
  }

  Future<void> logoutUser() async {
    final SharedPreferences _prefs = Get.find();
    await _prefs.remove(SPKeys.loginUserData.toString());
    Get.back();
    Get.offAll(() => SignInScreen());
  }

  Future<void> redirectUser({bool level}) async {
    if (isUserLoggedIn()) {
      if (getLoginData().data.role == 1) {
        Get.offAll(() => DashboardScreen(
              isMultiUser: false,
              isAdmin: false,
            ));
      } else {
        Get.offAll(() => DashboardScreen(
              isMultiUser: true,
              isAdmin: false,
            ));
      }
    } else {
      Get.offAll(() => SignInScreen());
    }
  }
//}
}
