import 'package:revo_pos/layers/domain/entities/report_orders_category.dart';

class ReportOrdersCategoryModel extends ReportOrdersCategory {
  final int? categoryId, countProducts, totalSales;
  final num? totalSalesFormated;
  final String? categoryName, image;

  ReportOrdersCategoryModel(
      {this.categoryId,
      this.countProducts,
      this.totalSales,
      this.categoryName,
      this.image,
      this.totalSalesFormated});

  factory ReportOrdersCategoryModel.fromJson(Map<String, dynamic> json) {
    return ReportOrdersCategoryModel(
        categoryId: json['category_id'],
        categoryName: json['category_name'],
        countProducts: json['count_products'],
        image: json['image'],
        totalSales: json['total_sales'].toInt(),
        totalSalesFormated: json['total_sales_formated'].toDouble());
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'count_products': countProducts,
      'image': image,
      'total_sales': totalSales,
      'total_sales_formated': totalSalesFormated
    };
  }
}
