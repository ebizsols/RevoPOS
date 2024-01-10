import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/check_price_model.dart';
import 'package:revo_pos/layers/domain/repositories/order_repository.dart';

class CheckPriceUsecase
    extends UseCase<List<CheckPriceModel>, CheckPriceParams> {
  final OrderRepository repository;

  CheckPriceUsecase(this.repository);

  @override
  Future<Either<Failure, List<CheckPriceModel>>> call(
      CheckPriceParams params) async {
    return await repository.checkPrice(
        userId: params.userId, lineItems: params.lineItems);
  }
}

class CheckPriceParams extends Equatable {
  final int userId;
  final List<LineItems> lineItems;

  const CheckPriceParams({required this.userId, required this.lineItems});

  @override
  List<Object> get props => [userId, lineItems];
}
