import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/setting_model.dart';
import 'package:revo_pos/layers/domain/entities/login.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> login(
      {String username, String password});
  Future<Either<Failure, List<SettingModel>>> getSettings();
  Future<Either<Failure, Map<String, dynamic>>> checkValidateCookie();
}
