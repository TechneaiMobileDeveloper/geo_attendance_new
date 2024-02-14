/// status : 1
/// message : "Record found !!!"
/// data : {"id":1,"tenant_id":null,"name":"aarti dalvi","token":"$2y$10$0FH/NLPjoDKC0egSzvPcduznpWx.0tuSiIa30H4DdfIRigWMN4Vrm","email":"aarti.dalvi@techneai.com","profile_picture":null}

class LoginResponse {
  LoginResponse({
    int status,
    String message,
    Data data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  LoginResponse.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  int _status;
  String _message;
  Data _data;

  LoginResponse copyWith({
    int status,
    String message,
    Data data,
  }) =>
      LoginResponse(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );

  int get status => _status;

  String get message => _message;

  Data get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data.toJson();
    }
    return map;
  }
}

/// id : 1
/// tenant_id : null
/// name : "aarti dalvi"
/// token : "$2y$10$0FH/NLPjoDKC0egSzvPcduznpWx.0tuSiIa30H4DdfIRigWMN4Vrm"
/// email : "aarti.dalvi@techneai.com"
/// profile_picture : null

class Data {
  Data({
    int id,
    dynamic tenantId,
    String name,
    String token,
    String email,
    int roleId,
    dynamic profilePicture,
  }) {
    _id = id;
    _tenantId = tenantId;
    _name = name;
    _token = token;
    _email = email;
    _profilePicture = profilePicture;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _tenantId = json['tenant_id'];
    _name = json['name'];
    _token = json['token'];
    _email = json['email'];
    _roleId = json['role_id'];
    _profilePicture = json['profile_picture'];
  }

  int _id;
  dynamic _tenantId;
  String _name;
  String _token;
  String _email;
  int _roleId;
  dynamic _profilePicture;

  Data copyWith({
    int id,
    dynamic tenantId,
    String name,
    String token,
    String email,
    int roleId,
    dynamic profilePicture,
  }) =>
      Data(
        id: id ?? _id,
        tenantId: tenantId ?? _tenantId,
        name: name ?? _name,
        token: token ?? _token,
        email: email ?? _email,
        roleId: roleId ?? roleId,
        profilePicture: profilePicture ?? _profilePicture,
      );

  int get id => _id;

  dynamic get tenantId => _tenantId;

  String get name => _name;

  String get token => _token;

  String get email => _email;

  int get role => _roleId;

  dynamic get profilePicture => _profilePicture;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['tenant_id'] = _tenantId;
    map['name'] = _name;
    map['token'] = _token;
    map['email'] = _email;
    map['role_id'] = _roleId;
    map['profile_picture'] = _profilePicture;
    return map;
  }
}
