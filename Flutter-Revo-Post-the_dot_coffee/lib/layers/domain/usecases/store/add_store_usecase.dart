import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/store_model.dart';
import 'package:revo_pos/layers/domain/repositories/store_repository.dart';

class AddStoreUsecase implements UseCase<StoreModel, AddStoreParams> {
  final StoreRepository repository;

  AddStoreUsecase(this.repository);

  @override
  Future<Either<Failure, StoreModel>> call(AddStoreParams params) async {
    return await repository.addStore(
        storeName: params.storeName,
        url: params.url,
        consumerKey: params.consumerKey,
        consumerSecret: params.consumerSecret,
        isLogin: params.isLogin,
        cookie: params.cookie);
  }
}

class AddStoreParams extends Equatable {
  final String storeName;
  final String url;
  final String consumerKey;
  final String consumerSecret;
  final bool isLogin;
  final String cookie;

  const AddStoreParams({required this.storeName, required this.url, required this.consumerKey,
      required this.consumerSecret, required this.isLogin, required this.cookie});

  @override
  List<Object> get props =>
      [storeName, url, consumerKey, consumerSecret, isLogin, cookie];
}
