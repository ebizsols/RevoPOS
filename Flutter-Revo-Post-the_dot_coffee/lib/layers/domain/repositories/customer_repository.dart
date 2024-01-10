import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/customer_model.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers(
      {String search, int page, int perPage, int price});
  Future<Either<Failure, Customer>> getCustomer({int? customerID});
  Future<Either<Failure, Map<String, dynamic>?>> addCustomer(
      {CustomerModel customer});
  Future<Either<Failure, Map<String, dynamic>?>> updateCustomer(
      {CustomerModel customer, int id});
  Future<Either<Failure, Map<String, dynamic>?>> deleteCustomer({int id});
}
