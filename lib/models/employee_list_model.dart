class EmployeeModel {
  final bool success;
  final String message;
  final List<Data> data;

  EmployeeModel({
    this.success,
    this.message,
    this.data,
  });

  EmployeeModel.fromJson(Map<String, dynamic> json)
      : success = json['success'] as bool,
        message = json['message'] as String,
        data = (json['data'] as List)?.map((dynamic e) => Data.fromJson(e as Map<String,dynamic>)).toList();

  Map<String, dynamic> toJson() => {
    'success' : success,
    'message' : message,
    'data' : data?.map((e) => e.toJson()).toList()
  };
}

class Data {
  final int empId;
  final String employee;

  Data({
    this.empId,
    this.employee,
  });

  Data.fromJson(Map<String, dynamic> json)
      : empId = json['emp_id'] as int,
        employee = json['employee'] as String;

  Map<String, dynamic> toJson() => {
    'emp_id' : empId,
    'employee' : employee
  };
}