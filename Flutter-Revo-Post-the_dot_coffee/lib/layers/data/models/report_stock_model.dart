import 'package:html_unescape/html_unescape.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/domain/entities/product_variation.dart';
import 'package:revo_pos/layers/domain/entities/report_stock.dart';

class ReportStockModel extends ReportStock {
  final String? name, type, status, stockStatus, image, productStatus;
  final int? id, stockQty;
  final num? regPrice, salePrice, wholePrice;
  final List<VariationsModel>? variations;

  ReportStockModel(
      {this.name,
      this.type,
      this.status,
      this.stockStatus,
      this.image,
      this.id,
      this.stockQty,
      this.regPrice,
      this.salePrice,
      this.wholePrice,
      this.variations,
      this.productStatus});

  factory ReportStockModel.fromJson(Map<String, dynamic> json) {
    var variations;
    if (json['variations'] != null) {
      variations = List.generate(json['variations'].length,
          (index) => VariationsModel.fromJson(json['variations'][index]));
    }
    return ReportStockModel(
        name: HtmlUnescape().convert(json['name']),
        type: json['type'],
        status: json['status'],
        productStatus: json['product_status'],
        stockStatus: json['stock_status'],
        image: json['image'],
        id: json['id'],
        stockQty: json['stock_quantity'],
        regPrice: json['regular_price'],
        salePrice: json['sale_price'],
        wholePrice: json['wholesale_price'],
        variations: variations);
  }

  Map<String, dynamic> toJson() {
    var variations;
    if (this.variations != null) {
      variations = this.variations!.map((v) => v.toJson()).toList();
    }
    return {
      'name': name,
      'type': type,
      'status': status,
      'stock_status': stockStatus,
      'image': image,
      'id': id,
      'stock_quantity': stockQty,
      'regular_price': regPrice,
      'sale_price': salePrice,
      'wholesale_price': wholePrice,
      'variations': variations
    };
  }
}

class VariationsModel {
  int? variationId, stockQty;
  List<Attr>? attributes;
  String? status, stockStatus;
  num? regPrice, salePrice, wholePrice;
  VariationsModel(
      {this.variationId,
      this.stockQty,
      this.attributes,
      this.status,
      this.stockStatus,
      this.regPrice,
      this.salePrice,
      this.wholePrice});
  factory VariationsModel.fromJson(Map<String, dynamic> json) {
    var attr;
    if (json['attributes'] != null) {
      attr = List.generate(json['attributes'].length,
          (index) => Attr.fromJson(json['attributes'][index]));
    }
    return VariationsModel(
        variationId: json['variation_id'],
        attributes: attr,
        status: json['status'],
        stockQty: json['stock_quantity'],
        stockStatus: json['stock_status'],
        regPrice: json['regular_price'],
        salePrice: json['sale_price'],
        wholePrice: json['wholesale_price']);
  }
  Map<String, dynamic> toJson() {
    var attr;
    if (this.attributes != null) {
      attr = this.attributes!.map((v) => v.toJson()).toList();
    }
    return {
      'attributes': attr,
      'variation_id': variationId,
      'status': status,
      'stock_quantity': stockQty,
      'stock_status': stockStatus,
      'regular_price': regPrice,
      'sale_price': salePrice,
      'wholesale_price': wholePrice
    };
  }
}

class Attr {
  String? attribute, value;
  Attr({this.attribute, this.value});
  factory Attr.fromJson(Map<String, dynamic> json) {
    return Attr(attribute: json['attribute'], value: json['value']);
  }
  Map<String, dynamic> toJson() {
    return {'attribute': attribute, 'value': value};
  }
}

class WholeSaleModel {
  String? type;
  int? value;

  WholeSaleModel({this.type, this.value});

  factory WholeSaleModel.fromJson(Map<String, dynamic> json) {
    return WholeSaleModel(type: json['type'], value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'value': value};
  }
}
