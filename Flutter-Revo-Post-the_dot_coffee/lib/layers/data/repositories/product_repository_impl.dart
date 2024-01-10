import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/data/models/product_attribute_model.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/data/models/variation_data_model.dart';
import 'package:revo_pos/layers/data/models/variation_model.dart';
import 'package:revo_pos/layers/data/sources/local/product_local_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/product_remote_data_source.dart';
import 'package:revo_pos/layers/domain/entities/image.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';
import 'package:revo_pos/layers/domain/repositories/product_repository.dart';

typedef _ListProductLoader = Future<List<Product>> Function();
typedef _ListAttributeLoader = Future<List<Attribute>> Function();
typedef _CheckVariationLoader = Future<Map<String, dynamic>> Function();
typedef _ImageLoader = Future<Map<String, dynamic>> Function();
typedef _StatusLoader = Future<Status> Function();
/*typedef _ProductLoader = Future<Product> Function();
typedef _MapLoader = Future<Map<String, dynamic>> Function();*/

class ProductRepositoryImpl extends ProductRepository {
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts(
      {String? search, int? categoryId, int? page}) async {
    return await _getProducts(() {
      return remoteDataSource.getProducts(
          search: search, categoryId: categoryId, page: page);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkVariation(
      {required String id, required List<VariationModel> variation}) async {
    return await _checkVariation(() {
      return remoteDataSource.checkVariation(id: id, variation: variation);
    });
  }

  @override
  Future<Either<Failure, List<Attribute>>> getAttribute(
      {String? cookie}) async {
    return await _getAttribute(() {
      return remoteDataSource.getAttribute(cookie: cookie);
    });
  }

  @override
  Future<Either<Failure, Status>> deleteProduct(
      {required String id, required String cookie}) async {
    return await _getStatus(() {
      return remoteDataSource.deleteProduct(id: id, cookie: cookie);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> insertImage(
      {required String title, required String image}) async {
    return await _insertImage(() {
      return remoteDataSource.insertImage(title: title, image: image);
    });
  }

  @override
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
      List<ProductAtributeModel>? productAttribute,
      List<int>? idImages,
      String? titleImage,
      String? image,
      List<String>? base64}) async {
    return await _getStatus(() async {
      dynamic images;
      idImages = [];
      if (titleImage != null && image != null) {
        if (base64!.isNotEmpty) {
          for (int i = 0; i < base64.length; i++) {
            images = await remoteDataSource.insertImage(
                title: "${i}_${titleImage}", image: base64[i]);
            printLog("tittle image: ${json.encode(images)}");
            idImages!.add(images["id"]);
          }
        }
      }
      printLog("id_images: ${idImages!.length}");
      return remoteDataSource.insertProduct(
          cookie: cookie,
          id: id,
          name: name,
          description: description,
          regularPrice: regularPrice,
          salePrice: salePrice,
          weight: weight,
          width: width,
          height: height,
          length: length,
          sku: sku,
          idCategories: idCategories,
          idImages: idImages,
          type: type,
          stockStatus: stockStatus,
          manageStock: manageStock,
          stock: stock,
          variationData: variationData ?? [],
          productAttribute: productAttribute ?? []);
    });
  }

  @override
  Future<Either<Failure, List<Product>>> scanBarcode({String? sku}) async {
    return await _scanBarcode(() {
      return remoteDataSource.scanBarcode(sku: sku!);
    });
  }

  Future<Either<Failure, List<Product>>> _getProducts(
      _ListProductLoader getProducts) async {
    try {
      final remote = await getProducts();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> _checkVariation(
      _CheckVariationLoader checkVariation) async {
    try {
      final remote = await checkVariation();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, List<Attribute>>> _getAttribute(
      _ListAttributeLoader getAttribute) async {
    try {
      final remote = await getAttribute();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> _insertImage(
      _ImageLoader imageLoader) async {
    try {
      final remote = await imageLoader();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Status>> _getStatus(_StatusLoader getStatus) async {
    try {
      final remote = await getStatus();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  /*Future<Either<Failure, Product>> _getProduct(
      _ProductLoader getProduct) async {
    try {
      final remote = await getProduct();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> _getMap(
      _MapLoader getMap) async {
    try {
      final remote = await getMap();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }*/

  Future<Either<Failure, List<Product>>> _scanBarcode(
      _ListProductLoader scanBarcode) async {
    try {
      final remote = await scanBarcode();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
