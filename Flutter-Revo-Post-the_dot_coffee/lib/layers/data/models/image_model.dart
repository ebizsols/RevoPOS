import 'package:revo_pos/layers/domain/entities/image.dart';

class ImageModel extends Image {
  final int? id;
  final String? image;

  ImageModel({this.id, this.image});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(id: json['id'], image: json['image']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image': image};
  }
}
