import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/setting_model.dart';
import 'package:revo_pos/layers/domain/repositories/auth_repository.dart';

class GetSettingsUsecase implements UseCase<List<SettingModel>, NoParams> {
  final AuthRepository repository;

  GetSettingsUsecase(this.repository);

  @override
  Future<Either<Failure, List<SettingModel>>> call(NoParams params) async {
    return await repository.getSettings();
  }
}