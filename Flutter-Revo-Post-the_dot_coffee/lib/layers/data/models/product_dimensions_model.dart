import 'package:revo_pos/layers/domain/entities/product_dimensions.dart';

class ProductDimensionsModel extends ProductDimensions {
  final String? length;
  final String? width;
  final String? height;

  ProductDimensionsModel({
    this.length,
    this.width,
    this.height,
  });

  factory ProductDimensionsModel.fromJson(Map<String, dynamic> json) {
    return ProductDimensionsModel(
      length: json['length'].toString(),
      width: json['width'].toString(),
      height: json['height'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'width': width,
      'height': height,
    };
  }
}
