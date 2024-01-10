import 'package:revo_pos/layers/domain/entities/product_meta_data.dart';

class ProductMetaDataModel extends ProductMetadata{
  final int? id;
  final String? key;
  final dynamic value;

  const ProductMetaDataModel({required this.id, required this.key, this.value});

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'key' : key,
      'value': value
    };
  }

  factory ProductMetaDataModel.fromJson(Map<String, dynamic> json) {
    return ProductMetaDataModel(
        id : json['id'],
        key : json['key'],
        value : json['value']
    );
  }
}