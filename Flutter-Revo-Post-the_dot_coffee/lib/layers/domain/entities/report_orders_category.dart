import 'package:equatable/equatable.dart';

class ReportOrdersCategory extends Equatable {
  final int? categoryId, countProducts, totalSales;
  final num? totalSalesFormated;
  final String? categoryName, image;

  ReportOrdersCategory(
      {this.categoryId,
      this.countProducts,
      this.totalSales,
      this.categoryName,
      this.image,
      this.totalSalesFormated});

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        totalSales,
        countProducts,
        image,
        totalSalesFormated
      ];
}
