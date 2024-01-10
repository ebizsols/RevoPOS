import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/data/models/product_attribute_model.dart';
import 'package:revo_pos/layers/data/models/variation_data_model.dart';
import 'package:revo_pos/layers/data/models/variation_model.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts(
      {String? search, int? categoryId, int? page});

  Future<Either<Failure, List<Attribute>>> getAttribute({String? cookie});

  Future<Either<Failure, Status>> deleteProduct(
      {required String id, required String cookie});

  Future<Either<Failure, Map<String, dynamic>>> insertImage(
      {required String title, required String image});

  Future<Either<Failure, Status>> insertProduct(
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
      required String type,
      String? stockStatus,
      bool? manageStock,
      int? stock,
      List<VariationData>? variationData,
      List<ProductAtributeModel> productAttribute,
      List<int>? idImages,
      String? titleImage,
      String? image,
      List<String> base64});

  Future<Either<Failure, List<Product>>> scanBarcode({String? sku});

  Future<Either<Failure, Map<String, dynamic>>> checkVariation(
      {required String id, required List<VariationModel> variation});
}
