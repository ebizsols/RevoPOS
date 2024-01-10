import 'package:equatable/equatable.dart';
import 'package:revo_pos/layers/data/models/report_stock_model.dart';

class ReportStock extends Equatable {
  final String? name, type, status, stockStatus, image, productStatus;
  final int? id, stockQty;
  final num? regPrice, salePrice, wholePrice;
  final List<VariationsModel>? variations;

  ReportStock(
      {this.name,
      this.type,
      this.status,
      this.stockStatus,
      this.image,
      this.id,
      this.stockQty,
      this.regPrice,
      this.salePrice,
      this.wholePrice,
      this.variations,
      this.productStatus});

  @override
  List<Object?> get props => [
        name,
        type,
        status,
        stockStatus,
        image,
        id,
        stockQty,
        regPrice,
        salePrice,
        wholePrice,
        variations
      ];
}
