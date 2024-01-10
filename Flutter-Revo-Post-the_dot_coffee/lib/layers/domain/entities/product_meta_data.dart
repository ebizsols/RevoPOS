import 'package:equatable/equatable.dart';

class ProductMetadata extends Equatable {
  final int? id;
  final String? key;
  final dynamic value;

  const ProductMetadata({this.id, this.key, this.value});

  @override
  List<Object?> get props => [
    id,
    key,
    value
  ];
}