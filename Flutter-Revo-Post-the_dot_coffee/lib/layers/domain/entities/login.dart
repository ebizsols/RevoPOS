import 'package:equatable/equatable.dart';
import 'package:revo_pos/layers/domain/entities/user.dart';

class Login extends Equatable {
  final String? cookie;
  final User? user;

  const Login({
    this.cookie,
    this.user,
  });

  @override
  List<Object?> get props => [
    cookie,
    user
  ];
}