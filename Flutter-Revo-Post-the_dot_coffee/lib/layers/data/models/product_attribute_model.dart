import 'package:revo_pos/layers/domain/entities/product_attribute.dart';

class ProductAttributeModel extends ProductAttribute {
  final int? id, position;
  final String? name, slug;
  final bool? visible, variation;
  final List<dynamic>? options;
  String? selectedAttrValue, selectedAttrName;

  ProductAttributeModel(
      {this.id,
      this.position,
      this.name,
      this.slug,
      this.selectedAttrName,
      this.selectedAttrValue,
      this.visible,
      this.variation,
      this.options});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'position': position,
      'name': name,
      'visible': visible,
      'variation': variation,
      'options': options,
      'selected_attr_name': selectedAttrName,
      'selected_attr_value': selectedAttrValue
    };
  }

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    String? selectedAttrName;
    if (json['id'] != 0) {
      selectedAttrName =
          'attribute_pa_${json['name'].toString().toLowerCase().replaceAll(' ', '-')}';
    } else {
      selectedAttrName =
          'attribute_${json['name'].toString().toLowerCase().replaceAll(' ', '-')}';
    }
    return ProductAttributeModel(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        position: json['position'],
        visible: json['visible'],
        variation: json['variation'],
        options: json['options'],
        selectedAttrName: selectedAttrName,
        selectedAttrValue: json['selected_attr_value']);
  }
}
