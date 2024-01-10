import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/domain/repositories/customer_repository.dart';

class GetCustomersUsecase extends UseCase<List<Customer>, CustomerParams> {
  final CustomerRepository repository;

  GetCustomersUsecase(this.repository);

  @override
  Future<Either<Failure, List<Customer>>> call(CustomerParams params) async {
    return await repository.getCustomers(
        search: params.search,
        page: params.page,
        perPage: params.perPage,
        price: params.price);
  }
}

class CustomerParams extends Equatable {
  final String search;
  final int page, perPage, price;

  const CustomerParams(
      {required this.search,
      required this.page,
      required this.perPage,
      required this.price});

  @override
  List<Object> get props => [search, page, perPage];
}

class GetCustomerUsecase extends UseCase<Customer, SingleCustomerParams> {
  final CustomerRepository repository;

  GetCustomerUsecase(this.repository);

  @override
  Future<Either<Failure, Customer>> call(SingleCustomerParams params) async {
    return await repository.getCustomer(customerID: params.customerID);
  }
}

class SingleCustomerParams extends Equatable {
  final int customerID;

  const SingleCustomerParams({required this.customerID});

  @override
  List<Object> get props => [customerID];
}
