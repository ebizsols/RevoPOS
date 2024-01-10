import 'dart:convert';

import 'package:http/http.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/check_price_model.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart' as checkout;
import 'package:revo_pos/layers/data/models/order_model.dart';
import 'package:revo_pos/layers/data/models/payment_gateway_model.dart';
import 'package:revo_pos/layers/data/models/place_order_model.dart';
import 'package:revo_pos/layers/data/models/shipping_method_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders(
      {String? search, int? page, int? perPage, String? status});
  Future<Map<String, dynamic>?> updateStatusOrder({String? status, int? id});
  Future<Map<String, dynamic>?> createOrder({checkout.CheckoutModel? order});
  Future<Map<String, dynamic>?> printInv(
      {required String cookie,
      required int idOrder,
      required String storeName,
      required String storePhone,
      required String storeAlamat});
  Future<List<PaymentGatewayModel>> getPaymentGateway();
  Future<List<ShippingMethodModel>> getShippingMethod(
      {int? userId, List<checkout.LineItemsModel>? lineItems});
  Future<List<CheckPriceModel>> checkPrice(
      {required int userId, required List<LineItems> lineItems});
  Future<Map<String, dynamic>> placeOrder(PlaceOrderModel order);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  @override
  Future<List<OrderModel>> getOrders(
      {String? search, int? page, int? perPage, String? status}) async {
    try {
      List orders = [];
      Map data = {
        'cookie': AppConfig.data!.getString('cookie'),
        'search': search,
        'page': page,
        'per_page': perPage,
        'status': status
      };
      printLog(json.encode(data), name: "Data Order :");
      var response = await baseAPI!.postAsync('home-api/list-orders', data,
          isCustom: true, printedLog: true);
      printLog("order : ${json.encode(response)}");
      if (response != null) {
        orders = response;
      } else {
        throw ServerException();
      }

      return orders.map((customer) => OrderModel.fromJson(customer)).toList();
    } catch (e) {
      printLog('Error');
      throw UnimplementedError();
    }
  }

  @override
  Future<Map<String, dynamic>?> updateStatusOrder(
      {String? status, int? id}) async {
    Map<String, dynamic>? result;
    try {
      Map data = {'status': status};
      printLog(data.toString(), name: "Param Update Status Order");
      var response =
          await baseAPI!.putAsync('orders/$id', data, printedLog: true);
      printLog(response.toString());

      result = response;
      return result;
    } catch (e) {
      printLog('Error');
      return result;
    }
  }

  @override
  Future<Map<String, dynamic>?> createOrder(
      {checkout.CheckoutModel? order}) async {
    Map<String, dynamic>? result;
    try {
      printLog(json.encode(order), name: "Place Order");
      var response =
          await baseAPI!.postAsync('orders', order!.toJson(), printedLog: true);
      printLog(response.toString());

      result = response;
      return result;
    } catch (e) {
      printLog('Error');
      return result;
    }
  }

  @override
  Future<Map<String, dynamic>> placeOrder(PlaceOrderModel order) async {
    Map<String, dynamic> result;
    try {
      printLog(json.encode(order), name: "Place Order");
      var response = await baseAPI!.postAsync('place-order', order.toJson(),
          isCustom: true, printedLog: true);
      printLog(response.toString());

      result = response;
      return result;
    } catch (e) {
      printLog('Error');
      throw UnimplementedError();
    }
  }

  @override
  Future<Map<String, dynamic>?> printInv(
      {required String cookie,
      required int idOrder,
      required String storeName,
      required String storePhone,
      required String storeAlamat}) async {
    Map<String, dynamic>? result;
    try {
      Map data = {
        "cookie": cookie,
        "id_order": idOrder,
        "nama_toko": storeName,
        "no_hp_toko": storePhone,
        "alamat_toko": storeAlamat
      };
      printLog(data.toString());
      var response = await baseAPI!
          .postAsync('print-inv', data, isCustom: true, printedLog: true);
      printLog(response.toString());

      result = response;
      return result;
    } catch (e) {
      printLog('Error');
      return result;
    }
  }

  @override
  Future<List<PaymentGatewayModel>> getPaymentGateway() async {
    try {
      List payments = [];
      var response =
          await baseAPI!.getAsync('payment_gateways', printedLog: true);

      if (response != null) {
        payments = json.decode((response as Response).body);
      } else {
        throw ServerException();
      }

      return payments
          .map((payment) => PaymentGatewayModel.fromJson(payment))
          .toList();
    } catch (e) {
      printLog('Error');
      throw UnimplementedError();
    }
  }

  @override
  Future<List<ShippingMethodModel>> getShippingMethod(
      {int? userId, List<checkout.LineItemsModel>? lineItems}) async {
    try {
      List shipping = [];
      Map data = {'user_id': userId, 'line_items': lineItems};
      var response = await baseAPI!.postAsync('shipping-methods', data,
          isCustom: true, printedLog: true);

      if (response != null) {
        shipping = response;
      } else {
        throw ServerException();
      }

      return shipping
          .map((shipping) => ShippingMethodModel.fromJson(shipping))
          .toList();
    } catch (e) {
      printLog('Error');
      throw UnimplementedError();
    }
  }

  @override
  Future<List<CheckPriceModel>> checkPrice(
      {required int userId, required List<LineItems> lineItems}) async {
    try {
      List result = [];
      Map data = {"user_id": userId, "line_items": lineItems};
      printLog(json.encode(data));
      var response = await baseAPI!.postAsync('product/check-price', data,
          isCustom: true, printedLog: true);
      printLog(json.encode(response));

      result = response;
      return result.map((result) => CheckPriceModel.fromJson(result)).toList();
    } catch (e) {
      printLog('Error');
      throw UnimplementedError();
    }
  }
}
