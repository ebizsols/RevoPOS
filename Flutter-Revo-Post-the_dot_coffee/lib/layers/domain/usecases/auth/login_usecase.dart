
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/login.dart';
import 'package:revo_pos/layers/domain/repositories/auth_repository.dart';

class LoginUsecase implements UseCase<Map<String, dynamic>, LoginParams> {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(LoginParams params) async {
    return await repository.login(
        username: params.username,
        password: params.password
    );
  }
}

class LoginParams extends Equatable {
  final String username;
  final String password;

  const LoginParams({required this.username, required this.password});

  @override
  List<Object> get props => [
    username,
    password
  ];
}