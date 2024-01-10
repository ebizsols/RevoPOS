import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/domain/repositories/order_repository.dart';

class CreateOrderUsecase
    extends UseCase<Map<String, dynamic>?, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrderUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(
      CreateOrderParams params) async {
    return await repository.createOrder(order: params.order);
  }
}

class CreateOrderParams extends Equatable {
  final CheckoutModel order;

  const CreateOrderParams({required this.order});

  @override
  List<Object> get props => [order];
}
