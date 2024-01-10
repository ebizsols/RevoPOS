import 'package:revo_pos/layers/domain/entities/status.dart';

class StatusModel extends Status {
  final int? id;
  final String? productId;
  final String? status;
  final String? variationId;

  StatusModel({
    this.id,
    this.productId,
    this.status,
    this.variationId
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id : json['id'],
      productId : json['product_id'],
      status : json['status'],
      variationId: json['variation_id']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'product_id' : productId,
      'status' : status,
      'variation_id' : variationId
    };
  }
}