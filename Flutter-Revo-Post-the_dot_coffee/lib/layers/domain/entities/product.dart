import 'package:equatable/equatable.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/domain/entities/item_image.dart';
import 'package:revo_pos/layers/domain/entities/product_attribute.dart';
import 'package:revo_pos/layers/domain/entities/product_dimensions.dart';
import 'package:revo_pos/layers/domain/entities/product_variation.dart';

import 'category.dart';
import 'links.dart';

class Product extends Equatable {
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
  final ProductDimensions? dimensions;
  final bool? shippingRequired;
  final bool? shippingTaxable;
  final String? shippingClass;
  final int? shippingClassId;
  final bool? reviewsAllowed;
  final String? averageRating;
  final int? ratingCount;
  final int? parentId;
  final String? purchaseNote;
  final List<Category>? categories;
  final List<ItemImage>? images;
  final List<ProductAttribute>? attributes;
  final List<ProductVariation>? variations;
  final int? menuOrder;
  final String? priceHtml;
  final List<int>? relatedIds;
  final String? stockStatus;
  final Links? links;
  int? quantity;
  double? priceUsed;
  int? selectedVariationId;
  String? selectedVariationName;
  final String? formattedPrice;
  final String? formattedSalePrice;
  List<CustomVariationModel>? customVariation;

  Product(
      {this.id,
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
      this.customVariation});

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        permalink,
        dateCreated,
        dateCreatedGmt,
        dateModified,
        dateModifiedGmt,
        type,
        status,
        featured,
        catalogVisibility,
        description,
        shortDescription,
        sku,
        price,
        regularPrice,
        salePrice,
        dateOnSaleFrom,
        dateOnSaleFromGmt,
        dateOnSaleTo,
        dateOnSaleToGmt,
        onSale,
        purchasable,
        totalSales,
        virtual,
        downloadable,
        downloadLimit,
        downloadExpiry,
        externalUrl,
        buttonText,
        taxStatus,
        taxClass,
        manageStock,
        stockQuantity,
        backorders,
        backordersAllowed,
        backordered,
        lowStockAmount,
        soldIndividually,
        weight,
        dimensions,
        shippingRequired,
        shippingTaxable,
        shippingClass,
        shippingClassId,
        reviewsAllowed,
        averageRating,
        ratingCount,
        parentId,
        purchaseNote,
        categories,
        images,
        attributes,
        variations,
        menuOrder,
        priceHtml,
        relatedIds,
        stockStatus,
        links,
        quantity,
        priceUsed,
        selectedVariationId,
        selectedVariationName,
        formattedPrice,
        formattedSalePrice,
        customVariation
      ];
}
