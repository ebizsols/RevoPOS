import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/coupon_model.dart';
import 'package:revo_pos/layers/data/sources/remote/coupon_remote_data_source.dart';
import 'package:revo_pos/layers/domain/repositories/coupon_repository.dart';

typedef _ListCouponLoader = Future<List<CouponModel>> Function();
typedef _ApplyCouponLoader = Future<CouponsModel> Function();

class CouponRepositoryImpl extends CouponRepository {
  final CouponRemoteDataSource remoteDataSource;

  CouponRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<CouponModel>>> getCoupons({String? code}) async {
    return await _getCoupons(() {
      return remoteDataSource.getCoupons(code: code);
    });
  }

  Future<Either<Failure, List<CouponModel>>> _getCoupons(
      _ListCouponLoader getCoupons) async {
    try {
      final remote = await getCoupons();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CouponsModel>> applyCoupons(
      {int? userId,
      List<LineItemsModel>? lineItems,
      String? couponCode}) async {
    return await _applyCoupons(() {
      return remoteDataSource.applyCoupons(
          userId: userId, lineItems: lineItems, couponCode: couponCode);
    });
  }

  Future<Either<Failure, CouponsModel>> _applyCoupons(
      _ApplyCouponLoader applyCoupons) async {
    try {
      final remote = await applyCoupons();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
