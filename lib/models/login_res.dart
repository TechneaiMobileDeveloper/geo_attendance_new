// import 'package:flutter/material.dart';
// import 'package:json_annotation/json_annotation.dart';
//
//  part 'login_res.g.dart';
//
// @JsonSerializable()
// class LoginResponse {
//   int status;
//   String message;
//   List<Data> data;
//
//   LoginResponse({this.status, this.message, this.data});
//
//   @override
//   String toString() => 'LoginResponse { status: $status }';
//
//   factory LoginResponse.fromJson(Map item) {
//     try {
//       return _$LoginResponseFromJson(item);
//     } catch (e) {
//       debugPrint("LoginResponse.fromJson has error $e");
//     }
//     return LoginResponse();
//   }
//
//   Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
// }
//
// @JsonSerializable()
// class Data {
//   int id;
//   int employeeId;
//   String employeeNm;
//   String remark;
//   String isActive;
//   int createdAt;
//   int updatedAt;
//
//   Data(
//       {this.id,
//       this.employeeId,
//       this.employeeNm,
//       this.remark,
//       this.isActive,
//       this.createdAt,
//       this.updatedAt});
//   @override
//   String toString() => 'Data { employeeId: $employeeId }';
//
//   factory Data.fromJson(Map item) {
//     try {
//       return _$DataFromJson(item);
//     } catch (e) {
//       debugPrint("Data.fromJson has error $e");
//     }
//     return Data();
//   }
//
//   Map<String, dynamic> toJson() => _$DataToJson(this);
// }
