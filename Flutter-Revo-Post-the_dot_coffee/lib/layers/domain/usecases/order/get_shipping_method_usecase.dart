import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/shipping_method_model.dart';
import 'package:revo_pos/layers/domain/repositories/order_repository.dart';

class GetShippingMethodUsecase
    extends UseCase<List<ShippingMethodModel>, ShippingMethodParams> {
  final OrderRepository repository;

  GetShippingMethodUsecase(this.repository);

  @override
  Future<Either<Failure, List<ShippingMethodModel>>> call(
      ShippingMethodParams params) async {
    return await repository.getShippingMethod(
        userId: params.userId, lineItems: params.lineItems);
  }
}

class ShippingMethodParams extends Equatable {
  final int userId;
  final List<LineItemsModel> lineItems;

  ShippingMethodParams({
    required this.userId,
    required this.lineItems,
  });

  @override
  List<Object> get props => [userId, lineItems];
}
