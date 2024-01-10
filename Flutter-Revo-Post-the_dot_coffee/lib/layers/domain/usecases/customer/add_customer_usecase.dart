import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/customer_model.dart';
import 'package:revo_pos/layers/domain/repositories/customer_repository.dart';

class AddCustomersUsecase
    extends UseCase<Map<String, dynamic>?, AddCustomerParams> {
  final CustomerRepository repository;

  AddCustomersUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(
      AddCustomerParams params) async {
    return await repository.addCustomer(customer: params.customer);
  }
}

class AddCustomerParams extends Equatable {
  final CustomerModel customer;

  const AddCustomerParams({required this.customer});

  @override
  List<Object> get props => [customer];
}
