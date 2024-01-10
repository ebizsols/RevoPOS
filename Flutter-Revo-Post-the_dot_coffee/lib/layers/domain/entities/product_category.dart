import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  final int? id;
  final String? name, slug;
  final dynamic image;

  const ProductCategory({this.id, this.name, this.slug, this.image});

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    image
  ];
}