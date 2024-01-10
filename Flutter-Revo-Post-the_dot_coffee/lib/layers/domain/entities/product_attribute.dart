import 'package:equatable/equatable.dart';

class ProductAttribute extends Equatable {
  final int? id, position;
  final String? name, slug;
  final bool? visible, variation;
  final List<dynamic>? options;
  String? selectedAttrValue, selectedAttrName;

  ProductAttribute(
      {this.id,
      this.position,
      this.name,
      this.slug,
      this.selectedAttrName,
      this.selectedAttrValue,
      this.visible,
      this.variation,
      this.options});

  @override
  List<Object?> get props => [
        id,
        position,
        name,
        slug,
        selectedAttrName,
        selectedAttrValue,
        visible,
        variation,
        options
      ];
}
