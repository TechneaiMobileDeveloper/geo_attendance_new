class Data {
  Data({
      this.id, 
      this.empId, 
      this.userName, 
      this.type, 
      this.date, 
      this.time, 
      this.location, 
      this.imagePath, 
      this.acceptance, 
      this.isMannualApprove, 
      this.createdAt, 
      this.updatedAt,});

  Data.fromJson(dynamic json) {
    id = json['id'];
    empId = json['emp_id'];
    userName = json['userName'];
    type = json['type'];
    date = json['date'];
    time = json['time'];
    location = json['location'];
    imagePath = json['image_path'];
    acceptance = json['acceptance'];
    isMannualApprove = json['is_mannual_approve'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  int id;
  int empId;
  dynamic userName;
  String type;
  String date;
  String time;
  String location;
  String imagePath;
  int acceptance;
  int isMannualApprove;
  dynamic createdAt;
  String updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['emp_id'] = empId;
    map['userName'] = userName;
    map['type'] = type;
    map['date'] = date;
    map['time'] = time;
    map['location'] = location;
    map['image_path'] = imagePath;
    map['acceptance'] = acceptance;
    map['is_mannual_approve'] = isMannualApprove;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}