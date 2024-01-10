import 'package:revo_pos/layers/domain/entities/product_image.dart';

class ProductImageModel extends ProductImage {
  final String? image;
  final String? type;
  final int? id;
  final String? src, name, alt;

  const ProductImageModel(
      {this.image, this.type, this.id, this.src, this.name, this.alt});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
        image: json['image'],
        type: json['type'],
        id: json['id'],
        src: json['src'],
        name: json['name'],
        alt: json['alt']);
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'type': type,
      'id': id,
      'src': src,
      'name': name,
      'alt': alt
    };
  }
}
