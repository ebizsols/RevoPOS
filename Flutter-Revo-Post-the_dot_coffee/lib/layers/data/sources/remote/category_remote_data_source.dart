import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories(
      {int? page, int? limit = 10, String? search});
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories(
      {int? page, int? limit = 10, String? search}) async {
    var searchVal = "";
    if (search != null) {
      searchVal = search;
    }
    log("Page : $page, Limit : $limit");
    try {
      List categories = [];
      var response = await baseAPI!.getAsync(
          'products/categories?search=$searchVal',
          isCustom: true,
          printedLog: false);
      printLog(json.encode(response.body), name: "Categoories");

      if (response != null) {
        categories = json.decode((response as Response).body);
      } else {
        throw ServerException();
      }

      return categories
          .map((category) => CategoryModel.fromJson(category))
          .toList();
    } catch (e) {
      printLog('Error');
      throw UnimplementedError();
    }
  }
}
