import 'dart:convert';

import 'package:dartz/dartz_unsafe.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/report_orders_category_model.dart';
import 'package:revo_pos/layers/data/models/report_orders_coupon_model.dart';
import 'package:revo_pos/layers/data/models/report_orders_model.dart';
import 'package:revo_pos/layers/data/models/report_stock_model.dart';
import 'package:revo_pos/layers/data/models/status_model.dart';
import 'package:revo_pos/layers/data/models/step_model.dart';
import 'package:revo_pos/layers/data/models/step_product_detail_model.dart';
import 'package:revo_pos/layers/data/models/step_product_model.dart';

abstract class ReportsRemoteDataSource {
  Future<List<ReportStockModel>> getProducts(
      {String? search, String? filter, int? page, int? productId});
  Future<Map<String, dynamic>> stocksUpdate({
    int? productId,
    String? type,
    bool? manageStock,
    String? stockStatus,
    int? stockQty,
    String? regPrice,
    String? salePrice,
    WholeSaleModel? wholeSale,
    List<Map<String, dynamic>>? variations,
    String? productStatus,
  });
  Future<dynamic> getReportOrders(
      {String? salesBy,
      String? period,
      String? step,
      int? productId,
      String? startDate,
      String? endDate});
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  @override
  Future<List<ReportStockModel>> getProducts(
      {String? search, String? filter, int? page, int? productId}) async {
    try {
      Map data = {};
      data['cookie'] = AppConfig.data!.getString('cookie');
      if (search != null) data["search"] = search;
      if (filter != null) data["filter"] = filter;
      if (page != null) data["page"] = page;
      if (productId != null) data["product_id"] = productId;
      data["per_page"] = 10;
      data["show"] = "all";
      printLog("data : ${json.encode(data)}");
      List products = [];
      var response = await baseAPI!
          .postAsync('report/stocks', data, isCustom: true, printedLog: false);

      if (response != null) {
        products = response;
      } else {
        throw ServerException();
      }
      printLog("products : ${json.encode(products)}");
      return products.map((prod) => ReportStockModel.fromJson(prod)).toList();
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }

  @override
  Future<Map<String, dynamic>> stocksUpdate({
    int? productId,
    String? type,
    bool? manageStock,
    String? stockStatus,
    int? stockQty,
    String? regPrice,
    String? salePrice,
    WholeSaleModel? wholeSale,
    List<Map<String, dynamic>>? variations,
    String? productStatus,
  }) async {
    try {
      Map data = {};
      data['cookie'] = AppConfig.data!.getString('cookie');
      if (productId != null) data["product_id"] = productId;
      if (type != null) data["type"] = type;
      if (manageStock != null) data['manage_stock'] = manageStock;
      if (stockStatus != null) data['stock_status'] = stockStatus;
      if (stockQty != null) data['stock_quantity'] = stockQty;
      if (regPrice != null) data["regular_price"] = regPrice;
      if (salePrice != null) data["sale_price"] = salePrice;
      if (wholeSale != null) data['wholesale'] = wholeSale;
      if (variations != null) data['variations'] = variations;
      if (productStatus != null) data['product_status'] = productStatus;

      printLog("data : ${json.encode(data)}");
      Map<String, dynamic> products;
      var response = await baseAPI!.postAsync('report/stocks-update', data,
          isCustom: true, printedLog: false);

      if (response != null) {
        products = response;
      } else {
        throw ServerException();
      }
      printLog("products : ${json.encode(products)}");
      return products;
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }

  @override
  Future<dynamic> getReportOrders(
      {String? salesBy,
      String? step,
      int? productId,
      String? period,
      String? startDate,
      String? endDate}) async {
    Map data = {};
    data['cookie'] = AppConfig.data!.getString('cookie');
    if (salesBy != null) data["sales_by"] = salesBy;
    if (period != null) data["period"] = period;
    if (step != null) data["step"] = step;
    if (productId != null) data['product_id'] = productId;
    if (startDate != null) data["start_date"] = startDate;
    if (endDate != null) data["end_date"] = endDate;

    printLog("data : ${json.encode(data)}");
    var reportOrder;
    var response = await baseAPI!
        .postAsync('report/orders', data, isCustom: true, printedLog: false);
    printLog("response : ${json.encode(response)}");
    if (response != null && salesBy == "date") {
      reportOrder = ReportOrdersModel.fromJson(response);
    } else if (response != null && salesBy == "product") {
      if (step == "") {
        List temp = [];
        response.forEach((v) {
          temp.add(StepModel.fromJson(v));
        });
        reportOrder = temp;
      } else if (step != "" && productId == null && step != null) {
        List temp = [];
        response.forEach((v) {
          temp.add(StepProductModel.fromJson(v));
        });
        reportOrder = temp;
      } else if (productId != null) {
        reportOrder = StepProductDetailModel.fromJson(response);
      }
    } else if (response != null && salesBy == "category") {
      List temp = [];
      response.forEach((v) {
        temp.add(ReportOrdersCategoryModel.fromJson(v));
      });
      reportOrder = temp;
    } else if (response != null && salesBy == "coupon") {
      reportOrder = ReportOrdersCouponModel.fromJson(response);
    } else {
      throw ServerException();
    }
    printLog("report order : ${json.encode(reportOrder)}");
    return reportOrder;
    try {} catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }
}
