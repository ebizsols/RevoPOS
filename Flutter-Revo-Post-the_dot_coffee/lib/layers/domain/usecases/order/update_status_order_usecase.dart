import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/repositories/order_repository.dart';

class UpdateStatusOrderUsecase
    extends UseCase<Map<String, dynamic>?, UpdateStatusOrderParams> {
  final OrderRepository repository;

  UpdateStatusOrderUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(
      UpdateStatusOrderParams params) async {
    return await repository.updateStatusOrder(
        status: params.status, id: params.id);
  }
}

class UpdateStatusOrderParams extends Equatable {
  final String status;
  final int id;

  const UpdateStatusOrderParams({required this.status, required this.id});

  @override
  List<Object> get props => [status, id];
}
