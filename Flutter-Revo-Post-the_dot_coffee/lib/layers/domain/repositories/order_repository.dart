import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/check_price_model.dart'
    as checkPrices;
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/place_order_model.dart';
import 'package:revo_pos/layers/data/models/shipping_method_model.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';
import 'package:revo_pos/layers/domain/entities/payment_gateway.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<Orders>>> getOrders(
      {String search, int page, int perPage, String status});
  Future<Either<Failure, Map<String, dynamic>?>> updateStatusOrder(
      {String status, int id});
  Future<Either<Failure, Map<String, dynamic>?>> createOrder(
      {CheckoutModel order});
  Future<Either<Failure, Map<String, dynamic>?>> printInv(
      {required String cookie,
      required int idOrder,
      required String storeName,
      required String storePhone,
      required String storeAlamat});
  Future<Either<Failure, List<PaymentGateway>>> getPaymentGateway();
  Future<Either<Failure, List<ShippingMethodModel>>> getShippingMethod(
      {int? userId, List<LineItemsModel>? lineItems});
  Future<Either<Failure, List<checkPrices.CheckPriceModel>>> checkPrice(
      {required int userId, required List<checkPrices.LineItems> lineItems});
  Future<Either<Failure, Map<String, dynamic>>> placeOrder(
      PlaceOrderModel order);
}
