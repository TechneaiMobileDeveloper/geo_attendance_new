import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geo_attendance_system/res/strings.dart';
import 'package:geo_attendance_system/utils/auth/auth_manager.dart';
import 'package:geo_attendance_system/utils/common.dart';
import 'package:geo_attendance_system/utils/methods.dart';
import 'package:get/get.dart' as g;

class APIClient {
  final AuthManager _authManager = g.Get.put(AuthManager());
  final Dio _dio = Dio();

  _requestHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic> queryParameters,
  }) async {
    Map<String, dynamic> responseData = Map();

    try {
      Response response = await _dio.get(
        Uri.encodeFull(path),
        queryParameters: queryParameters,
      );
      if (response.data.runtimeType == String) {
        if (response.data.toString().isNotEmpty)
          responseData = json.decode(response.data);
      } else
        responseData = response.data;
    } on DioError catch (e) {
      logErrorInFile(
          "${e.toString()},url:$path \n ${jsonEncode(queryParameters)}");
      if (e.response == null) throw e;
      if (e.response.statusCode == null) throw e;
      if (e.response.statusCode == 401) {
        log("unauthorized");
        Common.toast(Strings.sessionExpired);
        _authManager.logoutUser();
      } else
        throw e;
    }
    return responseData;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic> data,
    Map<String, dynamic> mapData,
    FormData formData,
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> headers,
    bool logoutOnUnauthorized = true,
  }) async {
    log("API URL $path");
    data != null
        ? log("API POST ${jsonEncode(data)}")
        : log("API POST ${jsonEncode(mapData)}");
    String bodyJsonString = jsonEncode(mapData);

    Map<String, dynamic> responseData = Map();
    try {
      Response response = await _dio.post(
        Uri.encodeFull(path),
        data: data != null ? FormData.fromMap(data) : bodyJsonString,
        options: Options(
          headers: headers ?? _requestHeaders(),
        ),
        queryParameters: queryParameters,
      );
      if (response.data.runtimeType == String) {
        responseData = json.decode(response.data);
      } else
        responseData = response.data;
    } on DioError catch (e) {
      logErrorInFile(
          "${e.toString()},url:$path \n ${jsonEncode(data)} , ${jsonEncode(mapData)}");
      if (e.response == null) throw e;
      if (e.response.statusCode == null) throw e;
      if (e.response.statusCode == 401 && logoutOnUnauthorized) {
        log("unauthorized");
        Common.toast(Strings.sessionExpired);
        _authManager.logoutUser();
      } else
        throw e;
    }

    return responseData;
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map data,
    FormData formData,
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> headers,
  }) async {
    log("API URL $path");
    Map<String, dynamic> responseData = Map();

    try {
      Response response = await _dio.patch(
        Uri.encodeFull(path),
        data: data ?? formData,
        options: Options(
          headers: headers ?? _requestHeaders(),
        ),
        queryParameters: queryParameters,
      );

      responseData = response.data;
    } on DioError catch (e) {
      if (e.response == null) throw e;
      if (e.response.statusCode == null) throw e;
      if (e.response.statusCode == 401) {
        log("unauthorized");
        Common.toast(Strings.sessionExpired);
        _authManager.logoutUser();
      } else
        throw e;
    }

    return responseData;
  }
}
