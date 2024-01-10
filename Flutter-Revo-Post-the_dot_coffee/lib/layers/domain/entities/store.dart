import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String? storeName;
  final String? url;
  final String? consumerKey;
  final String? consumerSecret;
  final bool? isLogin;
  final String? cookie;

  const Store({
    this.storeName,
    this.url,
    this.consumerKey,
    this.consumerSecret,
    this.isLogin,
    this.cookie
  });

  @override
  List<Object?> get props => [
    storeName,
    url,
    consumerKey,
    consumerSecret,
    isLogin,
    cookie
  ];
}