import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/check_price_model.dart';
import 'package:revo_pos/layers/data/models/place_order_model.dart';
import 'package:revo_pos/layers/domain/repositories/order_repository.dart';

class PlaceOrderUsecase
    extends UseCase<Map<String, dynamic>, PlaceOrderParams> {
  final OrderRepository repository;

  PlaceOrderUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      PlaceOrderParams params) async {
    return await repository.placeOrder(params.order);
  }
}

class PlaceOrderParams extends Equatable {
  final PlaceOrderModel order;

  const PlaceOrderParams({required this.order});

  @override
  List<Object> get props => [order];
}
