import 'package:equatable/equatable.dart';

class ProductDimensions extends Equatable {
  final String? length;
  final String? width;
  final String? height;

  ProductDimensions({
    this.length,
    this.width,
    this.height,
  });

  @override
  List<Object?> get props => [
        length,
        width,
        height,
      ];
}
