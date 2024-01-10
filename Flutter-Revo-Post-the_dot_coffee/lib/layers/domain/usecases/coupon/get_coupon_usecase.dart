import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/coupon_model.dart';
import 'package:revo_pos/layers/domain/repositories/coupon_repository.dart';

class GetCouponUsecase extends UseCase<List<CouponModel>, CouponParams> {
  final CouponRepository repository;

  GetCouponUsecase(this.repository);

  @override
  Future<Either<Failure, List<CouponModel>>> call(CouponParams params) async {
    return await repository.getCoupons(code: params.code);
  }
}

class CouponParams extends Equatable {
  final String code;

  const CouponParams(
      {required this.code});

  @override
  List<Object> get props => [code];
}
