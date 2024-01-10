import 'dart:convert';

import 'package:http/http.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers(
      {String? search, int? page, int? perPage, int? price});
  Future<CustomerModel> getCustomer({int? customerID});
  Future<Map<String, dynamic>?> addCustomer({CustomerModel? customer});
  Future<Map<String, dynamic>?> updateCustomer(
      {CustomerModel? customer, int? id});
  Future<Map<String, dynamic>?> deleteCustomer({int? id});
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  @override
  Future<List<CustomerModel>> getCustomers(
      {String? search, int? page, int? perPage, int? price}) async {
    try {
      List customers = [];
      // var response = await baseAPI!.getAsync(
      //     // 'customers?search=$search&page=$page&per_page=$perPage&orderby=registered_date&order=desc',
      //     'customers?search=$search&page=$page&per_page=$perPage&orderby=id&order=desc',
      //     printedLog: false);
      Map data = {
        "user_id": null,
        "search": search,
        "page": page,
        "per_page": perPage,
        "subtotal_order": price
      };
      printLog(json.encode(data), name: "Data");
      var response = await baseAPI!.postAsync('users', data, isCustom: true);
      printLog(json.encode(response), name: "Response customer");
      if (response != null) {
        customers = response;
      } else {
        throw ServerException();
      }

      return customers
          .map((customer) => CustomerModel.fromJson(customer))
          .toList();
    } catch (e) {
      printLog('Error');
      throw UnimplementedError();
    }
  }

  @override
  Future<CustomerModel> getCustomer({int? customerID}) async {
    try {
      CustomerModel customers;
      // var response =
      //     await baseAPI!.getAsync('customers/$customerID', printedLog: false);
      Map data = {"user_id": customerID};
      var response = await baseAPI!.postAsync('users', data, isCustom: true);
      if (response != null) {
        var customerResult = response;
        customers = CustomerModel.fromJson(customerResult);
      } else {
        throw ServerException();
      }

      return customers;
    } catch (e) {
      printLog('Error');
      throw UnimplementedError();
    }
  }

  @override
  Future<Map<String, dynamic>?> addCustomer({CustomerModel? customer}) async {
    Map<String, dynamic>? result;
    try {
      Map data = customer!.toJson();
      printLog(json.encode(data), name: "Add Customer");
      var response =
          await baseAPI!.postAsync('customers', data, printedLog: true);
      printLog(response.toString());

      result = response;
      return result;
    } catch (e) {
      printLog('Error');
      return result;
    }
  }

  @override
  Future<Map<String, dynamic>?> updateCustomer(
      {CustomerModel? customer, int? id}) async {
    Map<String, dynamic>? result;
    try {
      Map data = customer!.toJson();
      var response =
          await baseAPI!.putAsync('customers/$id', data, printedLog: true);
      printLog(response.toString());

      result = response;
      return result;
    } catch (e) {
      printLog('Error');
      return result;
    }
  }

  @override
  Future<Map<String, dynamic>?> deleteCustomer({int? id}) async {
    Map<String, dynamic>? result;
    try {
      Map data = {};
      var response =
          await baseAPI!.deleteAsync('customers/$id?force=true', data);
      printLog(response.toString());

      result = response;
      return result;
    } catch (e) {
      printLog('Error');
      return result;
    }
  }
}
