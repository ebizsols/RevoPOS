import 'package:equatable/equatable.dart';
import 'package:revo_pos/layers/domain/entities/item_image.dart';

import 'links.dart';

class Category extends Equatable {
  final int? id;
  final int? termId;
  final String? name;
  final String? slug;
  final int? parent;
  final String? description;
  final String? display;
  final ItemImage? image;
  final int? menuOrder;
  final int? count;
  final Links? links;
  final int? level;

  const Category({
    this.id,
    this.termId,
    this.name,
    this.slug,
    this.parent,
    this.description,
    this.display,
    this.image,
    this.menuOrder,
    this.count,
    this.links,
    this.level,
  });

  @override
  List<Object?> get props => [
        id,
        termId,
        name,
        slug,
        parent,
        description,
        display,
        image,
        menuOrder,
        count,
        links,
        level,
      ];
}
