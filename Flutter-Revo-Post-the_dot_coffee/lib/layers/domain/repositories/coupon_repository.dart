import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/coupon_model.dart';

abstract class CouponRepository {
  Future<Either<Failure, List<CouponModel>>> getCoupons({String code});
  Future<Either<Failure, CouponsModel>> applyCoupons(
      {int? userId, List<LineItemsModel>? lineItems, String? couponCode});
}
