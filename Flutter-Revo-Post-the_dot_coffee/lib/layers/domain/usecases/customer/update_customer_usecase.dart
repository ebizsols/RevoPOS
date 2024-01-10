import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/customer_model.dart';
import 'package:revo_pos/layers/domain/repositories/customer_repository.dart';

class UpdateCustomersUsecase
    extends UseCase<Map<String, dynamic>?, UpdateCustomerParams> {
  final CustomerRepository repository;

  UpdateCustomersUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(
      UpdateCustomerParams params) async {
    return await repository.updateCustomer(customer: params.customer, id: params.id);
  }
}

class UpdateCustomerParams extends Equatable {
  final CustomerModel customer;
  final int id;

  const UpdateCustomerParams({required this.customer, required this.id});

  @override
  List<Object> get props => [customer, id];
}
