import 'package:equatable/equatable.dart';
import 'package:revo_pos/layers/data/models/step_product_detail_model.dart';

class StepProductDetail extends Equatable {
  final int? productId, totalItems, maxY, loopY, formatedValue;
  final String? productName, productPrice, image, totalSales;
  final List<Totals>? totals;

  StepProductDetail(
      {this.productId,
      this.totalItems,
      this.maxY,
      this.loopY,
      this.formatedValue,
      this.productName,
      this.productPrice,
      this.image,
      this.totalSales,
      this.totals});

  @override
  List<Object?> get props => [
        productId,
        totalItems,
        maxY,
        loopY,
        formatedValue,
        productName,
        productPrice,
        image,
        totalSales,
        totals,
      ];
}
