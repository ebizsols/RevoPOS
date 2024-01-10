import 'package:equatable/equatable.dart';

class Status extends Equatable {
  final int? id;
  final String? productId;
  final String? status;
  final String? variationId;

  Status({
    this.id,
    this.productId,
    this.status,
    this.variationId
  });

  @override
  List<Object?> get props => [
    id,
    productId,
    status,
    variationId
  ];
}