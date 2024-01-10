import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/payment_gateway.dart';
import 'package:revo_pos/layers/domain/repositories/order_repository.dart';

class GetPaymentUsecase extends UseCase<List<PaymentGateway>, NoParams> {
  final OrderRepository repository;

  GetPaymentUsecase(this.repository);

  @override
  Future<Either<Failure, List<PaymentGateway>>> call(NoParams params) async {
    return await repository.getPaymentGateway();
  }
}
