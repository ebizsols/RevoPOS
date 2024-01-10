import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/setting_model.dart';
import 'package:revo_pos/layers/data/sources/remote/auth_remote_data_source.dart';
import 'package:revo_pos/layers/domain/repositories/auth_repository.dart';

typedef _UserLoader = Future<Map<String, dynamic>> Function();
typedef _SettingsLoader = Future<List<SettingModel>> Function();
typedef _CheckCookieLoader = Future<Map<String, dynamic>> Function();

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> login(
      {String? username, String? password}) async {
    return await _login(() {
      return remoteDataSource.login(username: username, password: password);
    });
  }

  Future<Either<Failure, Map<String, dynamic>>> _login(
      _UserLoader login) async {
    try {
      final remote = await login();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkValidateCookie() async {
    return await _CheckValidateCookie(() {
      return remoteDataSource.checkValidateCookie();
    });
  }

  Future<Either<Failure, Map<String, dynamic>>> _CheckValidateCookie(
      _CheckCookieLoader checkCookie) async {
    try {
      final remote = await checkCookie();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<SettingModel>>> getSettings() async {
    return await _getSettings(() {
      return remoteDataSource.getSettings();
    });
  }

  Future<Either<Failure, List<SettingModel>>> _getSettings(
      _SettingsLoader getSettings) async {
    try {
      final remote = await getSettings();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
