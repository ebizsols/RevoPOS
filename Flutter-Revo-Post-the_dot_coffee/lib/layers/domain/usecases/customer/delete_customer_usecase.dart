import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/repositories/customer_repository.dart';

class DeleteCustomersUsecase
    extends UseCase<Map<String, dynamic>?, DeleteCustomerParams> {
  final CustomerRepository repository;

  DeleteCustomersUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(
      DeleteCustomerParams params) async {
    return await repository.deleteCustomer(id: params.id);
  }
}

class DeleteCustomerParams extends Equatable {
  final int id;

  const DeleteCustomerParams({required this.id});

  @override
  List<Object> get props => [id];
}
