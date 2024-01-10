import 'dart:convert';

import 'package:http/http.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/coupon_model.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';

abstract class CouponRemoteDataSource {
  Future<List<CouponModel>> getCoupons({String? code});
  Future<CouponsModel> applyCoupons(
      {int? userId, List<LineItemsModel>? lineItems, String? couponCode});
}

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  @override
  Future<List<CouponModel>> getCoupons({String? code}) async {
    try {
      List coupons = [];
      var response =
          await baseAPI!.getAsync('coupons?code=$code', printedLog: true);
      printLog(response.toString());

      if (response != null) {
        coupons = json.decode((response as Response).body);
      } else {
        throw ServerException();
      }

      return coupons.map((coupon) => CouponModel.fromJson(coupon)).toList();
    } catch (e) {
      printLog('Error');
      throw UnimplementedError();
    }
  }

  @override
  Future<CouponsModel> applyCoupons(
      {int? userId,
      List<LineItemsModel>? lineItems,
      String? couponCode}) async {
    try {
      CouponsModel coupons;
      Map data = {
        'user_id': userId,
        'line_items': lineItems,
        'coupon_code': couponCode
      };
      printLog(json.encode(data), name: "apply coupon");

      var response = await baseAPI!
          .postAsync('apply-coupon', data, printedLog: true, isCustom: true);
      if (response != null) {
        var res = response;
        coupons = CouponsModel.fromJson(res);
      } else {
        throw ServerException();
      }

      return coupons;
    } catch (e) {
      printLog('Error');
      throw UnimplementedError();
    }
  }
}
