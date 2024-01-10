import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/store_model.dart';
import 'package:revo_pos/layers/data/models/user_setting_model.dart';
import 'package:revo_pos/layers/data/sources/remote/setting_remote_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/store_remote_data_source.dart';
import 'package:revo_pos/layers/domain/repositories/setting_repository.dart';
import 'package:revo_pos/layers/domain/repositories/store_repository.dart';

typedef _UserSettingLoader = Future<UserSettingModel> Function();

class SettingRepositoryImpl extends SettingRepository {
  final SettingRemoteDataSource remoteDataSource;

  SettingRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, UserSettingModel>> getUserSettings() async {
    return await _getUserSettings(() {
      return remoteDataSource.getUserSettings();
    });
  }

  Future<Either<Failure, UserSettingModel>> _getUserSettings(_UserSettingLoader getUserSettings) async {
    try {
      final remote = await getUserSettings();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
