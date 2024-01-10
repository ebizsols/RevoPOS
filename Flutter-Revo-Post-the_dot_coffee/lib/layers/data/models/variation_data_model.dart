import 'package:equatable/equatable.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';

class VariationData {
  String? varStockStatus,
      deleteProductVariant,
      variableProductId,
      varManageStock;
  List<Attribute>? listAttr;
  List<VariationAttributesModel>? listVariationAttr;
  String? width, length, height, weight;
  String? varRegularPrice, varSalePrice, varStock, variableSku;

  VariationData(
      {this.varManageStock,
      this.varRegularPrice,
      this.varSalePrice,
      this.varStock,
      this.varStockStatus,
      this.variableProductId,
      this.deleteProductVariant,
      this.height,
      this.length,
      this.weight,
      this.width,
      this.listAttr,
      this.variableSku,
      this.listVariationAttr});

  Map<String, dynamic> toJson() => {
        "delete_product_variant": deleteProductVariant,
        "variable_product_id": variableProductId,
        "variable_regular_price": varRegularPrice,
        "variable_sale_price": varSalePrice,
        "variable_stock_status": varStockStatus,
        "variable_manage_stock": varManageStock,
        "variable_stock": varStock,
        "variable_weight": weight,
        "variable_length": length,
        "variable_width": width,
        "variable_height": height,
        "variation_attributes": listVariationAttr,
        "variation_sku": variableSku
      };

  factory VariationData.fromJson(Map<String, dynamic> json) {
    var list;
    if (json['variation_attributes'] != null) {
      list = List.generate(
          json['variation_attributes'].length,
          (index) => VariationAttributesModel.fromJson(
              json["variation_attributes"][index]));
    }
    return VariationData(
        varRegularPrice: json['variable_regular_price'],
        varSalePrice: json['variable_sale_price'],
        varStockStatus: json['variable_stock_status'],
        varManageStock: json['variable_manage_stock'],
        varStock: json['variable_stock'],
        weight: json['variable_weight'],
        length: json['variable_length'],
        width: json['variable_width'],
        height: json['variable_height'],
        variableSku: json['variable_sku'],
        listVariationAttr: list);
  }
}

class VariationAttributesModel {
  int? id;
  String? attributeName, option;

  VariationAttributesModel({this.id, this.attributeName, this.option});

  Map<String, dynamic> toJson() => {
        "id": id,
        "attribute_name": attributeName,
        "option": option!.toLowerCase()
      };

  factory VariationAttributesModel.fromJson(Map<String, dynamic> json) {
    return VariationAttributesModel(
        id: json["id"],
        attributeName: json["attribute_name"],
        option: json["option"]);
  }
}
