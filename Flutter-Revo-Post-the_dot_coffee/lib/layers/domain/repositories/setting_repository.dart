import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/store_model.dart';
import 'package:revo_pos/layers/data/models/user_setting_model.dart';

abstract class SettingRepository {
  Future<Either<Failure, UserSettingModel>> getUserSettings();
}