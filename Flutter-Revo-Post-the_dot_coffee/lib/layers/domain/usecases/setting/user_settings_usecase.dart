import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/user_setting.dart';
import 'package:revo_pos/layers/domain/repositories/setting_repository.dart';

class GetUserSettingsUsecase extends UseCase<UserSetting, NoParams> {
  final SettingRepository repository;

  GetUserSettingsUsecase(this.repository);

  @override
  Future<Either<Failure, UserSetting>> call(NoParams params) async {
    return await repository.getUserSettings();
  }
}