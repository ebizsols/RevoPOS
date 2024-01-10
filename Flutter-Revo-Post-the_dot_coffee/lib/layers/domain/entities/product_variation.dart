import 'package:equatable/equatable.dart';
import 'package:revo_pos/layers/domain/entities/product_dimensions.dart';
import 'package:revo_pos/layers/domain/entities/product_image.dart';

class ProductVariation extends Equatable {
  final Attributes? attributes;
  final String? availabilityHtml;
  final bool? backordersAllowed;
  final ProductDimensions? dimensions;
  final String? dimensionsHtml;
  final num? displayPrice;
  final num? displayRegularPrice;
  final ProductImage? image;
  final int? imageId;
  final bool? isDownloadable;
  final bool? isInStock;
  final bool? isPurchasable;
  final String? isSoldIndividually;
  final bool? isVirtual;
  final dynamic maxQty;
  final dynamic minQty;
  final String? priceHtml;
  final String? sku;
  final String? variationDescription;
  final int? variationId;
  final bool? variationIsActive;
  final bool? variationIsVisible;
  final String? weight;
  final String? weightHtml;
  final List<ProductOption>? option;
  final String? formatedPrice;
  final String? formatedSalesPrice;

  const ProductVariation({
    this.attributes,
    this.availabilityHtml,
    this.backordersAllowed,
    this.dimensions,
    this.dimensionsHtml,
    this.displayPrice,
    this.displayRegularPrice,
    this.image,
    this.imageId,
    this.isDownloadable,
    this.isInStock,
    this.isPurchasable,
    this.isSoldIndividually,
    this.isVirtual,
    this.maxQty,
    this.minQty,
    this.priceHtml,
    this.sku,
    this.variationDescription,
    this.variationId,
    this.variationIsActive,
    this.variationIsVisible,
    this.weight,
    this.weightHtml,
    this.option,
    this.formatedPrice,
    this.formatedSalesPrice,
  });

  @override
  List<Object?> get props => [
    attributes,
    availabilityHtml,
    backordersAllowed,
    dimensions,
    dimensionsHtml,
    displayPrice,
    displayRegularPrice,
    image,
    imageId,
    isDownloadable,
    isInStock,
    isPurchasable,
    isSoldIndividually,
    isVirtual,
    maxQty,
    minQty,
    priceHtml,
    sku,
    variationDescription,
    variationId,
    variationIsActive,
    variationIsVisible,
    weight,
    weightHtml,
    option,
    formatedPrice,
    formatedSalesPrice,
  ];
}

class Attributes extends Equatable {
  final String? attributeSize;

  Attributes({
    this.attributeSize,
  });

  @override
  List<Object?> get props => [
    attributeSize,
  ];
}

class ProductOption extends Equatable {
  final String? key;
  final String? value;

  ProductOption({
    this.key,
    this.value,
  });

  @override
  List<Object?> get props => [
    key,
    value,
  ];
}