import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/coupon_model.dart';
import 'package:revo_pos/layers/domain/repositories/coupon_repository.dart';

class ApplyCouponUsecase extends UseCase<CouponsModel, ApplyCouponParams> {
  final CouponRepository repository;

  ApplyCouponUsecase(this.repository);

  @override
  Future<Either<Failure, CouponsModel>> call(ApplyCouponParams params) async {
    return await repository.applyCoupons(
        userId: params.userId,
        lineItems: params.lineItems,
        couponCode: params.couponCode);
  }
}

class ApplyCouponParams extends Equatable {
  final int userId;
  final List<LineItemsModel> lineItems;
  final String couponCode;

  const ApplyCouponParams(
      {required this.userId,
      required this.lineItems,
      required this.couponCode});

  @override
  List<Object> get props => [userId, lineItems, couponCode];
}
