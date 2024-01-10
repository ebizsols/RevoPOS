import 'dart:convert';

import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/data/models/product_attribute_model.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/data/models/product_variation_model.dart';
import 'package:revo_pos/layers/data/models/status_model.dart';
import 'package:revo_pos/layers/data/models/variation_data_model.dart';
import 'package:revo_pos/layers/data/models/variation_model.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts(
      {String? search, int? categoryId, int? page});

  Future<List<Attribute>> getAttribute({String? cookie});

  Future<StatusModel> deleteProduct(
      {required String id, required String cookie});

  Future<StatusModel> insertProduct(
      {required String cookie,
      String? id,
      required String name,
      required String description,
      int? regularPrice,
      int? salePrice,
      double? weight,
      double? width,
      double? height,
      double? length,
      String? sku,
      required List<int> idCategories,
      List<int>? idImages,
      required String type,
      String? stockStatus,
      bool? manageStock,
      int? stock,
      List<VariationData> variationData,
      List<ProductAtributeModel> productAttribute});

  Future<StatusModel> editProduct(
      {required String id,
      required String name,
      required String description,
      required int regularPrice,
      required int salePrice,
      required List<int> idCategories,
      required String type});

  Future<Map<String, dynamic>> insertImage(
      {required String title, required String image});

  Future<List<ProductModel>> scanBarcode({required String sku});

  Future<Map<String, dynamic>> checkVariation(
      {required String id, required List<VariationModel> variation});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<List<ProductModel>> getProducts(
      {String? search, int? categoryId, int? page}) async {
    try {
      Map data = {};
      if (search != null) data["search"] = search;
      if (categoryId != null) data["categories"] = categoryId;
      if (page != null) data["page"] = page;

      data["limit"] = 10;
      printLog("data : ${data}");
      List products = [];
      var response = await baseAPI!
          .postAsync('list-produk', data, isCustom: true, printedLog: false);

      if (response != null) {
        products = response;
      } else {
        throw ServerException();
      }
      printLog("products : ${json.encode(products)}");
      return products.map((prod) => ProductModel.fromJson(prod)).toList();
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }

  @override
  Future<Map<String, dynamic>> checkVariation(
      {required String id, required List<VariationModel> variation}) async {
    try {
      dynamic status;
      Product product;
      Map data = {"product_id": id, "variation": variation};
      printLog("data : ${json.encode(data)}");
      var response = await baseAPI!.postAsync(
          'home-api/check-produk-variation', data,
          isCustom: true, printedLog: false);

      if (response != null) {
        printLog("product : ${json.encode(response['data'])}");
        status = response;
      } else {
        throw ServerException();
      }

      return response;
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }

  @override
  Future<List<Attribute>> getAttribute({String? cookie}) async {
    try {
      Map data = {"cookie": cookie};
      List attributes = [];
      var response = await baseAPI!.postAsync('wc-attributes-term', data,
          isCustom: true, printedLog: false);

      if (response != null) {
        attributes = response;
      } else {
        throw ServerException();
      }
      return attributes.map((attr) => Attribute.fromJson(attr)).toList();
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }

  @override
  Future<StatusModel> deleteProduct(
      {required String id, required String cookie}) async {
    dynamic status;

    try {
      Map data = {"product_id": id, "cookie": cookie};
      var response = await baseAPI!.postAsync('delete-produk', data,
          version: 2, isCustom: false, printedLog: false);

      if (response != null) {
        printLog(json.encode(response));
        status = response;
      } else {
        throw ServerException();
      }

      return StatusModel.fromJson(status);
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }

  @override
  Future<StatusModel> insertProduct(
      {required String cookie,
      String? id,
      required String name,
      required String description,
      int? regularPrice,
      int? salePrice,
      double? weight,
      double? width,
      double? height,
      double? length,
      String? sku,
      required List<int> idCategories,
      List<int>? idImages,
      required String type,
      String? stockStatus,
      bool? manageStock,
      int? stock,
      List<VariationData>? variationData,
      List<ProductAtributeModel>? productAttribute}) async {
    dynamic status;

    try {
      Map data = {
        "cookie": cookie,
        "product_id": id,
        "title": name,
        "regular_price": regularPrice,
        "sale_price": salePrice,
        "content": description,
        "dimensions": {
          "weight": weight,
          "width": width,
          "length": length,
          "height": height,
        },
        "variation_data": variationData,
        "product_atribute": productAttribute,
        "sku": sku,
        "categories": idCategories,
        "product_type": type,
        "stock_status": stockStatus,
        "manage_stock": manageStock,
        "stock_quantity": stock,
        "status": "Publish",
        "image_ids": idImages?.map((e) => {"id": e}).toList()
      };

      if (id != null) {
        data["product_id"] = id;
      }

      printLog("data : ${json.encode(data)}");

      var response = await baseAPI!.postAsync('input-produk', data,
          version: 2, isCustom: false, printedLog: false);

      printLog("response : ${response}");

      if (response != null) {
        status = response;
      } else {
        throw ServerException();
      }
      printLog("status : ${status}");
      return StatusModel.fromJson(status);
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }

  @override
  Future<StatusModel> editProduct(
      {required String id,
      required String name,
      required String description,
      required int regularPrice,
      required int salePrice,
      required List<int> idCategories,
      required String type}) {
    // TODO: implement editProduct
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> insertImage(
      {required String title, required String image}) async {
    try {
      Map data = {"title": title, "media_attachment": image};
      var response = await baseAPI!.postAsync('upload-image', data,
          version: 2, isCustom: false, printedLog: false);
      if (response != null) {
        return response;
      } else {
        throw ServerException();
      }
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }

  @override
  Future<List<ProductModel>> scanBarcode({required String sku}) async {
    try {
      Map data = {"code": sku};
      List products = [];

      var response = await baseAPI!
          .postAsync('get-barcode', data, isCustom: true, printedLog: false);

      if (response['id'] != null) {
        Map _data = {'id': response['id']};

        var responseProduct = await baseAPI!
            .postAsync('list-produk', _data, isCustom: true, printedLog: true);

        if (responseProduct != null) {
          products = responseProduct;
          printLog(products.toString(), name: 'Response Scan');
        } else {
          throw ServerException();
        }

        return products.map((prod) => ProductModel.fromJson(prod)).toList();
      } else {
        return products.map((prod) => ProductModel.fromJson(prod)).toList();
      }
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }
}
