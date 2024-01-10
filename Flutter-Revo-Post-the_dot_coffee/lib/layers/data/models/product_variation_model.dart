import 'package:revo_pos/layers/data/models/product_dimensions_model.dart';
import 'package:revo_pos/layers/data/models/product_image_model.dart';
import 'package:revo_pos/layers/domain/entities/product_variation.dart';

class ProductVariationModel extends ProductVariation {
  final AttributesModel? attributes;
  final String? availabilityHtml;
  final bool? backordersAllowed;
  final ProductDimensionsModel? dimensions;
  final String? dimensionsHtml;
  final num? displayPrice;
  final num? displayRegularPrice;
  final ProductImageModel? image;
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
  final List<ProductOptionModel>? option;
  final String? formatedPrice;
  final String? formatedSalesPrice;

  ProductVariationModel({
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

  factory ProductVariationModel.fromJson(Map<String, dynamic> json) {
    var attributes;
    if (json['attributes'] != null) {
      attributes = AttributesModel.fromJson(json['attributes']);
    }

    var dimensions;
    if (json['dimensions'] != null) {
      dimensions = ProductDimensionsModel.fromJson(json['dimensions']);
    }

    var image;
    if (json['image'] != null) {
      image = ProductImageModel.fromJson(json['image']);
    }

    var option;
    if (json['option'] != null) {
      option = List.generate(json['option'].length, (index) =>
          ProductOptionModel.fromJson(json['option'][index]));
    }

    return ProductVariationModel(
      attributes : attributes,
      availabilityHtml : json['availability_html'],
      backordersAllowed : json['backorders_allowed'],
      dimensions : dimensions,
      dimensionsHtml : json['dimensions_html'],
      displayPrice : json['display_price'],
      displayRegularPrice : json['display_regular_price'],
      image : image,
      imageId : json['image_id'],
      isDownloadable : json['is_downloadable'],
      isInStock : json['is_in_stock'],
      isPurchasable : json['is_purchasable'],
      isSoldIndividually : json['is_sold_individually'],
      isVirtual : json['is_virtual'],
      maxQty : json['max_qty'],
      minQty : json['min_qty'],
      priceHtml : json['price_html'],
      sku : json['sku'],
      variationDescription : json['variation_description'],
      variationId : json['variation_id'],
      variationIsActive : json['variation_is_active'],
      variationIsVisible : json['variation_is_visible'],
      weight : json['weight'],
      weightHtml : json['weight_html'],
      option : option,
      formatedPrice : json['formated_price'],
      formatedSalesPrice : json['formated_sales_price'],
    );
  }

  Map<String, dynamic> toJson() {
    var attributes;
    if (this.attributes != null) {
      attributes = this.attributes!.toJson();
    }

    var dimensions;
    if (this.dimensions != null) {
      dimensions = this.dimensions!.toJson();
    }

    var image;
    if (this.image != null) {
      image = this.image!.toJson();
    }

    var option;
    if (this.option != null) {
      option = this.option!.map((v) => v.toJson()).toList();
    }

    return {
      'attributes' : attributes,
      'availability_html' : availabilityHtml,
      'backorders_allowed' : backordersAllowed,
      'dimensions' : dimensions,
      'dimensions_html' : dimensionsHtml,
      'display_price' : displayPrice,
      'display_regular_price' : displayRegularPrice,
      'image' : image,
      'image_id' : imageId,
      'is_downloadable' : isDownloadable,
      'is_in_stock' : isInStock,
      'is_purchasable' : isPurchasable,
      'is_sold_individually' : isSoldIndividually,
      'is_virtual' : isVirtual,
      'max_qty' : maxQty,
      'min_qty' : minQty,
      'price_html' : priceHtml,
      'sku' : sku,
      'variation_description' : variationDescription,
      'variation_id' : variationId,
      'variation_is_active' : variationIsActive,
      'variation_is_visible' : variationIsVisible,
      'weight' : weight,
      'weight_html' : weightHtml,
      'option' : option,
      'formated_price' : formatedPrice,
      'formated_sales_price' : formatedSalesPrice,
    };
  }
}

class AttributesModel extends Attributes {
  final String? attributeSize;

  AttributesModel({
    this.attributeSize,
  });

  factory AttributesModel.fromJson(Map<String, dynamic> json) {
    return AttributesModel(
      attributeSize : json['attribute_size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attribute_size' : attributeSize,
    };
  }
}

class ProductOptionModel extends ProductOption {
  final String? key;
  final String? value;

  ProductOptionModel({
    this.key,
    this.value,
  });

  factory ProductOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductOptionModel(
      key : json['key'],
      value : json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key' : key,
      'value' : value,
    };
  }
}