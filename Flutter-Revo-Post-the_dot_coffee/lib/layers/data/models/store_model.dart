import 'package:revo_pos/layers/data/models/login_model.dart';

class StoreModel {
  String? storeName;
  String? url;
  String? consumerKey;
  String? consumerSecret;
  bool? isLogin;
  String? cookie;
  LoginModel? user;

  StoreModel(
      {this.storeName,
      this.url,
      this.consumerKey,
      this.consumerSecret,
      this.isLogin,
      this.cookie,
      this.user});

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    LoginModel? user;
    if (json['user'] != null) {
      user = LoginModel.fromJson(json['user']);
    }

    return StoreModel(
        storeName: json['store_name'],
        url: json['url'],
        consumerKey: json['consumer_key'],
        consumerSecret: json['consumer_secret'],
        isLogin: json['is_login'],
        cookie: json['cookie'],
        user: user);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? user;
    if (this.user != null) {
      user = this.user!.toJson();
    }

    return {
      'store_name': storeName,
      'url': url,
      'consumer_key': consumerKey,
      'consumer_secret': consumerSecret,
      'is_login': isLogin,
      'cookie': cookie,
      'user': user
    };
  }

  @override
  String toString() {
    return 'StoreModel{storeName: $storeName, url: $url, consumerKey: $consumerKey, consumerSecret: $consumerSecret, isLogin: $isLogin, cookie: $cookie, user: $user}';
  }
}
