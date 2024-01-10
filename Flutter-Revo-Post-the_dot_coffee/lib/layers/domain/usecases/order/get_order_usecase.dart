import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';
import 'package:revo_pos/layers/domain/repositories/order_repository.dart';

class GetOrderUsecase extends UseCase<List<Orders>, OrderParams> {
  final OrderRepository repository;

  GetOrderUsecase(this.repository);

  @override
  Future<Either<Failure, List<Orders>>> call(OrderParams params) async {
    return await repository.getOrders(
        search: params.search,
        page: params.page,
        perPage: params.perPage,
        status: params.status);
  }
}

class OrderParams extends Equatable {
  final String search, status;
  final int page, perPage;

  const OrderParams(
      {required this.search,
      required this.page,
      required this.perPage,
      required this.status});

  @override
  List<Object> get props => [search, page, perPage, status];
}
