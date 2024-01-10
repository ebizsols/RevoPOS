import 'package:revo_pos/layers/data/models/user_model.dart';
import 'package:revo_pos/layers/domain/entities/login.dart';

class LoginModel extends Login {
  final String? cookie;
  final UserModel? user;

  const LoginModel({
    this.cookie,
    this.user,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    UserModel? user;
    if (json['user'] != null) {
      user = UserModel.fromJson(json['user']);
    }

    return LoginModel(
      cookie : json['cookie'],
      user : user,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? user;
    if (this.user != null) {
      user = this.user!.toJson();
    }
    return {
      'cookie' : cookie,
      'user' : user
    };
  }
}