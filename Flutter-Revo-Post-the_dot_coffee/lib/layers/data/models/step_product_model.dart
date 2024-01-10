import 'package:revo_pos/layers/domain/entities/step_product.dart';

class StepProductModel extends StepProduct {
  final String? productId, productName, image, total;

  StepProductModel({this.productId, this.productName, this.image, this.total});

  factory StepProductModel.fromJson(Map<String, dynamic> json) {
    return StepProductModel(
        productId: json['product_id'],
        productName: json['product_name'],
        image: json['image'],
        total: json['total']);
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'image': image,
      'total': total
    };
  }
}
