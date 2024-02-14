// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'login_res.dart';
//
// // **************************************************************************
// // JsonSerializableGenerator
// // **************************************************************************
//
// LoginResponse _$LoginResponseFromJson(Map json) {
//   return LoginResponse(
//     status: json['status'] as int,
//     message: json['message'] as String,
//     data: json['data'] == null ? null : List.from(json['data']).map((e) => Data.fromJson(e)).toList(),
//   );
// }
//
// Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
//     <String, dynamic>{
//       'status': instance.status,
//       'message': instance.message,
//       'data': instance.data,
//     };
//
// Data _$DataFromJson(Map json) {
//   return Data(
//     id:         json['id'] as int,
//     employeeId: json['employee_id'] as int,
//     employeeNm: json['employee_nm'] as String,
//     remark:     json['remark'] as String,
//     isActive:   json['is_active'] as String,
//     createdAt:  json['created_at'] as int,
//     updatedAt:  json['updated_at'] as int,
//   );
// }
//
// Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
//       'id': instance.id,
//       'employee_id': instance.employeeId,
//       'employee_nm': instance.employeeNm,
//       'remark': instance.remark,
//       'is_active': instance.isActive,
//       'created_at': instance.createdAt,
//       'updated_at': instance.updatedAt,
//     };
