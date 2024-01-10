import 'package:revo_pos/layers/domain/entities/user.dart';

class UserModel extends User {
  final int? id;
  final String? username,
      niceName,
      email,
      url,
      registered,
      displayName,
      firstname,
      lastname,
      nickname,
      description,
      avatar;

  final List<String>? role;

  const UserModel(
      {this.id,
      this.username,
      this.niceName,
      this.email,
      this.url,
      this.registered,
      this.displayName,
      this.firstname,
      this.lastname,
      this.nickname,
      this.description,
      this.avatar,
      this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String>? role;

    if (json['role'] != null) {
      role =
          List.generate(json['role'].length, (index) => json['role'][index]);
    }

    return UserModel(
        id: json['id'] ?? json['ID'],
        username: json['username'],
        nickname: json['nickname'],
        niceName: json['nicename'],
        email: json['email'],
        url: json['url'],
        registered: json['registered'],
        displayName: json['displayname'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        description: json['description'],
        avatar: json['avatar'],
        role: role);
  }

  Map<String, dynamic> toJson() {
    List<String>? role;
    if (this.role != null) {
      role = this.role;
    }

    return {
      'id': id,
      'username': username,
      'nicename': niceName,
      'email': email,
      'url': url,
      'registered': registered,
      'displayname': displayName,
      'firstname': firstname,
      'lastname': lastname,
      'nickname': nickname,
      'description': description,
      'avatar': avatar,
      'role': role
    };
  }
}
