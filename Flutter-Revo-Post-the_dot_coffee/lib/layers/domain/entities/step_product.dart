import 'package:equatable/equatable.dart';

class StepProduct extends Equatable {
  final String? productId, productName, image, total;
  StepProduct({this.productId, this.productName, this.image, this.total});
  @override
  List<Object?> get props => [productId, productName, image, total];
}
