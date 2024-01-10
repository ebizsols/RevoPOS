import 'package:revo_pos/core/utils/html_unescape.dart';
import 'package:revo_pos/layers/data/models/category_model.dart';
import 'package:revo_pos/layers/data/models/item_image_model.dart';
import 'package:revo_pos/layers/data/models/product_attribute_model.dart';
import 'package:revo_pos/layers/data/models/product_dimensions_model.dart';
import 'package:revo_pos/layers/data/models/product_variation_model.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';

import 'links_model.dart';

class ProductModel extends Product {
  final int? id;
  final String? name;
  final String? slug;
  final String? permalink;
  final dynamic dateCreated;
  final dynamic dateCreatedGmt;
  final dynamic dateModified;
  final dynamic dateModifiedGmt;
  final String? type;
  final String? status;
  final bool? featured;
  final String? catalogVisibility;
  final String? description;
  final String? shortDescription;
  final String? sku;
  final num? price;
  final num? regularPrice;
  final num? salePrice;
  final dynamic dateOnSaleFrom;
  final dynamic dateOnSaleFromGmt;
  final dynamic dateOnSaleTo;
  final dynamic dateOnSaleToGmt;
  final bool? onSale;
  final bool? purchasable;
  final int? totalSales;
  final bool? virtual;
  final bool? downloadable;
  final int? downloadLimit;
  final int? downloadExpiry;
  final String? externalUrl;
  final String? buttonText;
  final String? taxStatus;
  final String? taxClass;
  final bool? manageStock;
  final int? stockQuantity;
  final String? backorders;
  final bool? backordersAllowed;
  final bool? backordered;
  final int? lowStockAmount;
  final bool? soldIndividually;
  final String? weight;
  final ProductDimensionsModel? dimensions;
  final bool? shippingRequired;
  final bool? shippingTaxable;
  final String? shippingClass;
  final int? shippingClassId;
  final bool? reviewsAllowed;
  final String? averageRating;
  final int? ratingCount;
  final int? parentId;
  final String? purchaseNote;
  final List<CategoryModel>? categories;
  final List<ItemImageModel>? images;
  final List<ProductAttributeModel>? attributes;
  final List<ProductVariationModel>? variations;
  final int? menuOrder;
  final String? priceHtml;
  final List<int>? relatedIds;
  final String? stockStatus;
  final LinksModel? links;
  int? quantity;
  double? priceUsed;
  int? selectedVariationId;
  String? selectedVariationName;
  final String? formattedPrice;
  final String? formattedSalePrice;
  List<CustomVariationModel>? customVariation = [];

  ProductModel({
    this.id,
    this.name,
    this.slug,
    this.permalink,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.type,
    this.status,
    this.featured,
    this.catalogVisibility,
    this.description,
    this.shortDescription,
    this.sku,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.dateOnSaleFrom,
    this.dateOnSaleFromGmt,
    this.dateOnSaleTo,
    this.dateOnSaleToGmt,
    this.onSale,
    this.purchasable,
    this.totalSales,
    this.virtual,
    this.downloadable,
    this.downloadLimit,
    this.downloadExpiry,
    this.externalUrl,
    this.buttonText,
    this.taxStatus,
    this.taxClass,
    this.manageStock,
    this.stockQuantity,
    this.backorders,
    this.backordersAllowed,
    this.backordered,
    this.lowStockAmount,
    this.soldIndividually,
    this.weight,
    this.dimensions,
    this.shippingRequired,
    this.shippingTaxable,
    this.shippingClass,
    this.shippingClassId,
    this.reviewsAllowed,
    this.averageRating,
    this.ratingCount,
    this.parentId,
    this.purchaseNote,
    this.categories,
    this.images,
    this.attributes,
    this.variations,
    this.menuOrder,
    this.priceHtml,
    this.relatedIds,
    this.stockStatus,
    this.links,
    this.quantity,
    this.priceUsed,
    this.selectedVariationId,
    this.selectedVariationName,
    this.formattedPrice,
    this.formattedSalePrice,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var dimensions;
    if (json['dimensions'] != null) {
      dimensions = ProductDimensionsModel.fromJson(json['dimensions']);
    }

    var categories;
    if (json['categories'] != null && json['categories'] != false) {
      categories = List.generate(json['categories'].length,
          (index) => CategoryModel.fromJson(json['categories'][index]));
    }

    var images;
    if (json['images'] != null) {
      images = List.generate(json['images'].length,
          (index) => ItemImageModel.fromJson(json['images'][index]));
    }

    var attributes;
    if (json['attributes_v2'] != null) {
      attributes = List.generate(
          json['attributes_v2'].length,
          (index) =>
              ProductAttributeModel.fromJson(json['attributes_v2'][index]));
    }

    var variations;
    if (json['availableVariations'] != null) {
      variations = List.generate(
          json['availableVariations'].length,
          (index) => ProductVariationModel.fromJson(
              json['availableVariations'][index]));
    }

    var links;
    if (json['_links'] != null) {
      links = LinksModel.fromJson(json['_links']);
    }

    return ProductModel(
      id: json['id'],
      name: Unescape.htmlToString(json['name']),
      slug: json['slug'],
      permalink: json['permalink'],
      dateCreated: json['date_created'],
      dateCreatedGmt: json['date_created_gmt'],
      dateModified: json['date_modified'],
      dateModifiedGmt: json['date_modified_gmt'],
      type: json['type'],
      status: json['status'],
      featured: json['featured'],
      catalogVisibility: json['catalog_visibility'],
      description: json['description'],
      shortDescription: json['short_description'],
      sku: json['sku'],
      price: json['price'],
      regularPrice: json['regular_price'],
      salePrice: json['sale_price'],
      dateOnSaleFrom: json['date_on_sale_from'],
      dateOnSaleFromGmt: json['date_on_sale_from_gmt'],
      dateOnSaleTo: json['date_on_sale_to'],
      dateOnSaleToGmt: json['date_on_sale_to_gmt'],
      onSale: json['on_sale'],
      purchasable: json['purchasable'],
      totalSales: int.parse(json['total_sales'].toString()),
      virtual: json['virtual'],
      downloadable: json['downloadable'],
      downloadLimit: json['download_limit'],
      downloadExpiry: json['download_expiry'],
      externalUrl: json['external_url'],
      buttonText: json['button_text'],
      taxStatus: json['tax_status'],
      taxClass: json['tax_class'],
      manageStock: json['manage_stock'],
      stockQuantity: json['stock_quantity'],
      backorders: json['backorders'],
      backordersAllowed: json['backorders_allowed'],
      backordered: json['backordered'],
      lowStockAmount: json['low_stock_amount'],
      soldIndividually: json['sold_individually'],
      weight: json['dimensions']['weight'].toString(),
      dimensions: dimensions,
      shippingRequired: json['shipping_required'],
      shippingTaxable: json['shipping_taxable'],
      shippingClass: json['shipping_class'],
      shippingClassId: json['shipping_class_id'],
      reviewsAllowed: json['reviews_allowed'],
      averageRating: json['average_rating'],
      ratingCount: json['rating_count'],
      parentId: json['parent_id'],
      purchaseNote: json['purchase_note'],
      categories: categories,
      images: images,
      attributes: attributes,
      variations: variations,
      menuOrder: json['menu_order'],
      priceHtml: json['price_html'],
      stockStatus: json['stock_status'],
      links: links,
      quantity: json['quantity'],
      priceUsed: json['price_used'],
      selectedVariationId: json['variation_id'],
      selectedVariationName: json['variation_name'],
      formattedPrice: json['formated_price'],
      formattedSalePrice: json['formated_sales_price'],
    );
  }

  Map<String, dynamic> toJson() {
    var dimensions;
    if (this.dimensions != null) {
      dimensions = this.dimensions!.toJson();
    }

    var categories;
    if (this.categories != null) {
      categories = this.categories!.map((v) => v.toJson()).toList();
    }

    var images;
    if (this.images != null) {
      images = this.images!.map((v) => v.toJson()).toList();
    }

    var attributes;
    if (this.attributes != null) {
      attributes = this.attributes!.map((v) => v.toJson()).toList();
    }

    var variations;
    if (this.variations != null) {
      variations = this.variations!.map((v) => v.toJson()).toList();
    }

    var links;
    if (this.links != null) {
      links = this.links!.toJson();
    }

    return {
      'id': id,
      'name': name,
      'slug': slug,
      'permalink': permalink,
      'date_created': dateCreated,
      'date_created_gmt': dateCreatedGmt,
      'date_modified': dateModified,
      'date_modified_gmt': dateModifiedGmt,
      'type': type,
      'status': status,
      'featured': featured,
      'catalog_visibility': catalogVisibility,
      'description': description,
      'short_description': shortDescription,
      'sku': sku,
      'price': price,
      'regular_price': regularPrice,
      'sale_price': salePrice,
      'date_on_sale_from': dateOnSaleFrom,
      'date_on_sale_from_gmt': dateOnSaleFromGmt,
      'date_on_sale_to': dateOnSaleTo,
      'date_on_sale_to_gmt': dateOnSaleToGmt,
      'on_sale': onSale,
      'purchasable': purchasable,
      'total_sales': totalSales,
      'virtual': virtual,
      'downloadable': downloadable,
      'download_limit': downloadLimit,
      'download_expiry': downloadExpiry,
      'external_url': externalUrl,
      'button_text': buttonText,
      'tax_status': taxStatus,
      'tax_class': taxClass,
      'manage_stock': manageStock,
      'stock_quantity': stockQuantity,
      'backorders': backorders,
      'backorders_allowed': backordersAllowed,
      'backordered': backordered,
      'low_stock_amount': lowStockAmount,
      'sold_individually': soldIndividually,
      'weight': weight,
      'dimensions': dimensions,
      'shipping_required': shippingRequired,
      'shipping_taxable': shippingTaxable,
      'shipping_class': shippingClass,
      'shipping_class_id': shippingClassId,
      'reviews_allowed': reviewsAllowed,
      'average_rating': averageRating,
      'rating_count': ratingCount,
      'parent_id': parentId,
      'purchase_note': purchaseNote,
      'categories': categories,
      'images': images,
      'attributes_v2': attributes,
      'availableVariations': variations,
      'menu_order': menuOrder,
      'price_html': priceHtml,
      'stock_status': stockStatus,
      '_links': links,
      'quantity': quantity,
      'price_used': priceUsed,
      'variation_id': selectedVariationId,
      'variation_name': selectedVariationName,
      'formated_price': formattedPrice,
      'formated_sales_price': formattedSalePrice,
    };
  }
}

class CustomVariationModel {
  int? id;
  String? slug, name;
  String? selectedValue;
  String? selectedName;
  List<OptionVariation>? optionVariation;

  CustomVariationModel(
      {this.id,
      this.slug,
      this.name,
      this.selectedValue,
      this.optionVariation,
      this.selectedName});

  CustomVariationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    selectedValue = json['selected_value'];
    selectedName = json['selected_name'];
    if (json['option_variation'] != null) {
      optionVariation = <OptionVariation>[];
      json['option_variation'].forEach((v) {
        optionVariation!.add(new OptionVariation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['slug'] = this.slug;
    data['name'] = this.name;
    data['selected_value'] = this.selectedValue;
    data['selected_name'] = this.selectedName;
    if (this.optionVariation != null) {
      data['option_variation'] =
          this.optionVariation!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OptionVariation {
  String? value;
  String? image;
  String? name;

  OptionVariation({this.value, this.image, this.name});

  OptionVariation.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    image = json['image'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['image'] = this.image;
    data['name'] = this.name;
    return data;
  }
}
