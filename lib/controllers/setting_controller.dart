import 'package:flutter/cupertino.dart';
import 'package:geo_attendance_system/network/urls.dart';
import 'package:geo_attendance_system/utils/shared_pref_manager/sp_keys.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingController extends GetxController {
  final dropdownValue = "http".obs;
  final ipAddress = TextEditingController();
  final _prefs = Get.find<SharedPreferences>();

  @override
  void onInit() {
    initData();
    super.onInit();
  }

  setHttpMethod() {
    _prefs.setString(SPKeys.httpMethod.toString(), dropdownValue.value);
  }

  getHttpMethod() {
    return _prefs.getString(SPKeys.httpMethod.toString());
  }

  setIp() {
    _prefs.setString(SPKeys.ipAddress.toString(), ipAddress.text);
  }

  getIp() {
    return _prefs.getString(SPKeys.ipAddress.toString());
  }

  void initData() {
    if (getHttpMethod() != null) {
      dropdownValue.value = getHttpMethod();
    }
    if (getIp() != null) {
      ipAddress.text = getIp();
    } else {
      ipAddress.text = AppUrl.urlBase().replaceAll("http://", "");
    }
  }
}
