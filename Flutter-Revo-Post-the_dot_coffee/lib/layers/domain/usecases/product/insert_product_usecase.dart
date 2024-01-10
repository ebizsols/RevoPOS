import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/data/models/product_attribute_model.dart';
import 'package:revo_pos/layers/data/models/variation_data_model.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';
import 'package:revo_pos/layers/domain/repositories/product_repository.dart';

class InsertProductUsecase extends UseCase<Status, InsertProductParams> {
  final ProductRepository repository;

  InsertProductUsecase(this.repository);

  @override
  Future<Either<Failure, Status>> call(InsertProductParams params) async {
    return await repository.insertProduct(
        cookie: params.cookie,
        id: params.id,
        name: params.name,
        description: params.description,
        regularPrice: params.regularPrice,
        salePrice: params.salePrice,
        weight: params.weight,
        width: params.width,
        height: params.height,
        length: params.length,
        sku: params.sku,
        idCategories: params.idCategories,
        type: params.type,
        stockStatus: params.stockStatus,
        manageStock: params.manageStock,
        stock: params.stock,
        variationData: params.variationData,
        productAttribute: params.productAttribute ?? [],
        titleImage: params.titleImage,
        image: params.image,
        idImages: params.idImages,
        base64: params.base64 ?? []);
  }
}

class InsertProductParams extends Equatable {
  final String cookie;
  final String? id;
  final String name;
  final String description;
  final int? regularPrice;
  final int? salePrice;
  final double? weight;
  final double? width;
  final double? height;
  final double? length;
  final String? sku;
  final List<int> idCategories;
  final List<int>? idImages;
  final String type;
  final String? stockStatus;
  final bool? manageStock;
  final int? stock;
  final List<VariationData>? variationData;
  final List<ProductAtributeModel>? productAttribute;
  final String titleImage;
  final String image;
  final List<String>? base64;

  const InsertProductParams(
      {required this.cookie,
      this.id,
      required this.name,
      required this.description,
      this.regularPrice,
      this.salePrice,
      this.weight,
      this.width,
      this.height,
      this.length,
      this.sku,
      required this.idCategories,
      required this.type,
      this.stockStatus,
      this.manageStock,
      this.stock,
      this.variationData,
      this.productAttribute,
      required this.titleImage,
      required this.image,
      this.idImages,
      this.base64});

  @override
  List<Object?> get props => [
        cookie,
        id,
        name,
        description,
        regularPrice,
        salePrice,
        weight,
        width,
        height,
        length,
        sku,
        idCategories,
        type,
        stockStatus,
        manageStock,
        stock,
        variationData,
        productAttribute,
        titleImage,
        image,
        idImages,
        base64
      ];
}
