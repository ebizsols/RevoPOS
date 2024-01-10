import 'package:equatable/equatable.dart';

class User extends Equatable {
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

  const User(
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

  @override
  List<Object?> get props => [
    id,
    username,
    niceName,
    email,
    url,
    registered,
    displayName,
    firstname,
    lastname,
    nickname,
    description,
    avatar,
    role
  ];
}