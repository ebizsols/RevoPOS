import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/store_model.dart';
import 'package:revo_pos/layers/data/sources/remote/store_remote_data_source.dart';
import 'package:revo_pos/layers/domain/repositories/store_repository.dart';

typedef _ListStoreLoader = Future<List<StoreModel>> Function();
typedef _AddStoreLoader = Future<StoreModel> Function();

class StoreRepositoryImpl extends StoreRepository {
  final StoreRemoteDataSource remoteDataSource;

  StoreRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<StoreModel>>> getStores() async {
    return await _getStores(() {
      return remoteDataSource.getStores();
    });
  }

  Future<Either<Failure, List<StoreModel>>> _getStores(
      _ListStoreLoader getStores) async {
    try {
      final remote = await getStores();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, StoreModel>> addStore(
      {String? storeName,
      String? url,
      String? consumerKey,
      String? consumerSecret,
      bool? isLogin,
      String? cookie}) async {
    return await _addStore(() {
      return remoteDataSource.addStore(
          storeName: storeName,
          url: url,
          consumerKey: consumerKey,
          consumerSecret: consumerSecret,
          isLogin: isLogin,
          cookie: cookie);
    });
  }

  Future<Either<Failure, StoreModel>> _addStore(_AddStoreLoader addStore) async {
    try {
      final remote = await addStore();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
