import 'package:revo_pos/core/utils/html_unescape.dart';
import 'package:revo_pos/layers/data/models/item_image_model.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';

import 'links_model.dart';

class CategoryModel extends Category {
  final int? id;
  final int? termId;
  final String? name;
  final String? slug;
  final int? parent;
  final String? description;
  final String? display;
  final ItemImageModel? image;
  final int? menuOrder;
  final int? count;
  final LinksModel? links;
  final int? level;

  CategoryModel({
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

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    var image;
    if (json['image'] != null) {
      image = ItemImageModel.fromJson(json['image']);
    }

    var links;
    if (json['_links'] != null) {
      links = LinksModel.fromJson(json['_links']);
    }

    return CategoryModel(
      id: json['id'],
      termId: json['term_id'],
      name: Unescape.htmlToString(json['name']),
      slug: json['slug'],
      parent: json['parent'],
      description: json['description'],
      display: json['display'],
      image: image,
      menuOrder: json['menu_order'],
      count: json['count'],
      links: links,
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() {
    var image;
    if (this.image != null) {
      image = this.image!.toJson();
    }

    var links;
    if (this.links != null) {
      links = this.links!.toJson();
    }

    return {
      'id': id,
      'term_id': termId,
      'name': name,
      'slug': slug,
      'parent': parent,
      'description': description,
      'display': display,
      'image': image,
      'menu_order': menuOrder,
      'count': count,
      '_links': links,
      'level': level,
    };
  }
}
