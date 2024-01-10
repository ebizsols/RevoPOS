import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/customer_model.dart';
import 'package:revo_pos/layers/data/sources/remote/customer_remote_data_source.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/domain/repositories/customer_repository.dart';

typedef _ListCustomerLoader = Future<List<Customer>> Function();
typedef _CustomerLoader = Future<Customer> Function();
typedef _AddCustomerLoader = Future<Map<String, dynamic>?> Function();
typedef _UpdateCustomerLoader = Future<Map<String, dynamic>?> Function();
typedef _DeleteCustomerLoader = Future<Map<String, dynamic>?> Function();

class CustomerRepositoryImpl extends CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>?>> addCustomer(
      {CustomerModel? customer}) async {
    return await _addCustomer(() {
      return remoteDataSource.addCustomer(customer: customer);
    });
  }

  @override
  Future<Either<Failure, List<Customer>>> getCustomers(
      {String? search, int? page, int? perPage, int? price}) async {
    return await _getCustomers(() {
      return remoteDataSource.getCustomers(
          search: search, page: page, perPage: perPage, price: price);
    });
  }

  @override
  Future<Either<Failure, Customer>> getCustomer({int? customerID}) async {
    return await _getCustomer(() {
      return remoteDataSource.getCustomer(customerID: customerID);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> updateCustomer(
      {CustomerModel? customer, int? id}) async {
    return await _updateCustomer(() {
      return remoteDataSource.updateCustomer(customer: customer, id: id);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> deleteCustomer(
      {int? id}) async {
    return await _deleteCustomer(() {
      return remoteDataSource.deleteCustomer(id: id);
    });
  }

  Future<Either<Failure, List<Customer>>> _getCustomers(
      _ListCustomerLoader getCustomers) async {
    try {
      final remote = await getCustomers();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Customer>> _getCustomer(
      _CustomerLoader getCustomer) async {
    try {
      final remote = await getCustomer();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> _addCustomer(
      _AddCustomerLoader addCustomers) async {
    try {
      final remote = await addCustomers();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> _updateCustomer(
      _UpdateCustomerLoader updateCustomers) async {
    try {
      final remote = await updateCustomers();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> _deleteCustomer(
      _DeleteCustomerLoader deleteCustomers) async {
    try {
      final remote = await deleteCustomers();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
