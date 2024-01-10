import 'package:revo_pos/layers/domain/entities/item_image.dart';

class ItemImageModel extends ItemImage {
  final int? id;
  final String? dateCreated;
  final String? dateCreatedGmt;
  final String? dateModified;
  final String? dateModifiedGmt;
  final String? src;
  final String? name;
  final String? alt;

  ItemImageModel({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.src,
    this.name,
    this.alt,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json) {
    return ItemImageModel(
      id : json['id'],
      dateCreated : json['date_created'],
      dateCreatedGmt : json['date_created_gmt'],
      dateModified : json['date_modified'],
      dateModifiedGmt : json['date_modified_gmt'],
      src : json['src'],
      name : json['name'],
      alt : json['alt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'date_created' : dateCreated,
      'date_created_gmt' : dateCreatedGmt,
      'date_modified' : dateModified,
      'date_modified_gmt' : dateModifiedGmt,
      'src' : src,
      'name' : name,
      'alt' : alt,
    };
  }
}