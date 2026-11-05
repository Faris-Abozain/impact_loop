class LoginModel {
  final LoginModelData? data;
  final String? message;
  final int? code;

  @override
  String toString() {
    return 'LoginModel{data: $data, message: $message, code: $code}';
  }

  LoginModel({
    this.data,
    this.message,
    this.code,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        data:
            json["data"] == null ? null : LoginModelData.fromJson(json["data"]),
        message: json["code"] == 422 ? '' : json["message"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "message": message,
        "code": code,
      };
}

class LoginModelData {
  final User? user;
  final String? accessToken;
  final String? tokenType;

  LoginModelData({
    this.user,
    this.accessToken,
    this.tokenType,
  });

  factory LoginModelData.fromJson(Map<String, dynamic> json) => LoginModelData(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        accessToken: json["access_token"],
        tokenType: json["token_type"],
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "access_token": accessToken,
        "token_type": tokenType,
      };
}

class User {
  final int? id;
  String? name;
  final dynamic phoneCode;
  final String? phone;
  final String? email;
  final dynamic location;
  final int? status;
  final String? image;
  final int? userType;

  User({
    this.id,
    this.name,
    this.phoneCode,
    this.phone,
    this.email,
    this.location,
    this.status,
    this.image,
    this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        phoneCode: json["phone_code"],
        phone: json["phone"],
        email: json["email"],
        location: json["location"],
        status: json["status"],
        image: json["image"],
        userType: json["user_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone_code": phoneCode,
        "phone": phone,
        "email": email,
        "location": location,
        "status": status,
        "image": image,
        "user_type": userType,
      };
}
