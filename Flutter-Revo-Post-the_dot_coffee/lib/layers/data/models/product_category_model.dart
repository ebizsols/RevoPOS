import 'package:revo_pos/layers/domain/entities/product_category.dart';

class ProductCategoryModel extends ProductCategory {
  final int? id;
  final String? name, slug;
  final dynamic image;

  const ProductCategoryModel({this.id, this.name, this.slug, this.image});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug, 'image': image};
  }

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    dynamic image;
    if (json['image'] != null && json['image'] != '') {
      if (json['image'] != false && json['image']['src'] != false) {
        image = json['image']['src'];
      }
    }
    return ProductCategoryModel(
        id: json['id'], name: json['name'], slug: json['slug'], image: image);
  }
}
