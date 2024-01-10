import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/check_price_model.dart'
    as checkPrices;
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/place_order_model.dart';
import 'package:revo_pos/layers/data/models/shipping_method_model.dart';
import 'package:revo_pos/layers/data/sources/remote/order_remote_data_source.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';
import 'package:revo_pos/layers/domain/entities/payment_gateway.dart';
import 'package:revo_pos/layers/domain/repositories/order_repository.dart';

typedef _ListOrderLoader = Future<List<Orders>> Function();
typedef _UpdateStatusOrderLoader = Future<Map<String, dynamic>?> Function();
typedef _CreateOrderLoader = Future<Map<String, dynamic>?> Function();
typedef _PrintInvLoader = Future<Map<String, dynamic>?> Function();
typedef _ListPaymentLoader = Future<List<PaymentGateway>> Function();
typedef _ListShippingMethodLoader = Future<List<ShippingMethodModel>>
    Function();

typedef _ListCheckPriceLoader = Future<List<checkPrices.CheckPriceModel>>
    Function();
typedef _PlaceOrderLoader = Future<Map<String, dynamic>> Function();

class OrderRepositoryImpl extends OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Orders>>> getOrders(
      {String? search, int? page, int? perPage, String? status}) async {
    return await _getOrders(() {
      return remoteDataSource.getOrders(
          search: search, page: page, perPage: perPage, status: status);
    });
  }

  @override
  Future<Either<Failure, List<ShippingMethodModel>>> getShippingMethod(
      {int? userId, List<LineItemsModel>? lineItems}) async {
    return await _getShippingMethod(() {
      return remoteDataSource.getShippingMethod(
          userId: userId, lineItems: lineItems);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> updateStatusOrder(
      {String? status, int? id}) async {
    return await _updateStatusOrder(() {
      return remoteDataSource.updateStatusOrder(status: status, id: id);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> createOrder(
      {CheckoutModel? order}) async {
    return await _createOrder(() {
      return remoteDataSource.createOrder(order: order);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> placeOrder(
      PlaceOrderModel order) async {
    return await _placeOrder(() {
      return remoteDataSource.placeOrder(order);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> printInv(
      {required String cookie,
      required int idOrder,
      required String storeName,
      required String storePhone,
      required String storeAlamat}) async {
    return await _printInv(() {
      return remoteDataSource.printInv(
          cookie: cookie,
          idOrder: idOrder,
          storeName: storeName,
          storePhone: storePhone,
          storeAlamat: storeAlamat);
    });
  }

  @override
  Future<Either<Failure, List<PaymentGateway>>> getPaymentGateway() async {
    return await _getPaymentGateway(() {
      return remoteDataSource.getPaymentGateway();
    });
  }

  @override
  Future<Either<Failure, List<checkPrices.CheckPriceModel>>> checkPrice(
      {required int userId,
      required List<checkPrices.LineItems> lineItems}) async {
    return await _checkPrice(() {
      return remoteDataSource.checkPrice(userId: userId, lineItems: lineItems);
    });
  }

  Future<Either<Failure, List<Orders>>> _getOrders(
      _ListOrderLoader getOrders) async {
    try {
      final remote = await getOrders();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, List<ShippingMethodModel>>> _getShippingMethod(
      _ListShippingMethodLoader getShippingMethod) async {
    try {
      final remote = await getShippingMethod();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> _updateStatusOrder(
      _UpdateStatusOrderLoader updateStatusOrder) async {
    try {
      final remote = await updateStatusOrder();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> _createOrder(
      _CreateOrderLoader createOrder) async {
    try {
      final remote = await createOrder();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> _placeOrder(
      _PlaceOrderLoader placeOrder) async {
    try {
      final remote = await placeOrder();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> _printInv(
      _PrintInvLoader printInv) async {
    try {
      final remote = await printInv();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, List<PaymentGateway>>> _getPaymentGateway(
      _ListPaymentLoader getPaymentGateway) async {
    try {
      final remote = await getPaymentGateway();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, List<checkPrices.CheckPriceModel>>> _checkPrice(
      _ListCheckPriceLoader checkPriceLoader) async {
    try {
      final remote = await checkPriceLoader();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
