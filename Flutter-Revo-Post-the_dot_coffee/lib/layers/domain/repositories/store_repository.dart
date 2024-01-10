import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/store_model.dart';

abstract class StoreRepository {
  Future<Either<Failure, List<StoreModel>>> getStores();
  Future<Either<Failure, StoreModel>> addStore(
      {String storeName,
      String url,
      String consumerKey,
      String consumerSecret,
      bool isLogin,
      String cookie});
}