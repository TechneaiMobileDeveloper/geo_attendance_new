// // dao/person_dao.dart
//
// import 'package:floor/floor.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:geo_attendance_system/database/entity/attendance.dart';
//
// @dao
// abstract class AttendanceDao {
//   @Query('SELECT * FROM Attendance')
//   Future<List<Attendance>> findAllPersons();
//
//   @Query('SELECT * FROM Attendance WHERE id = :id')
//   Stream<Attendance> findPersonById(int id);
//
//   @insert
//   Future<void> insertPerson(Attendance person);
// }
