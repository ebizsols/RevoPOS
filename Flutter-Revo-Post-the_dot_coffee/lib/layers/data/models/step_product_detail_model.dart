import 'package:revo_pos/layers/domain/entities/step_product_detail.dart';

class StepProductDetailModel extends StepProductDetail {
  final int? productId, totalItems, maxY, loopY, formatedValue;
  final String? productName, productPrice, image, totalSales;
  final List<Totals>? totals;

  StepProductDetailModel(
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

  factory StepProductDetailModel.fromJson(Map<String, dynamic> json) {
    var total;
    if (json['totals'] != null) {
      total = List.generate(json['totals'].length,
          (index) => Totals.fromJson(json['totals'][index]));
    }
    return StepProductDetailModel(
        productId: json['product_id'],
        productName: json['product_name'],
        productPrice: json['product_price'],
        image: json['image'],
        totalSales: json['total_sales'],
        totalItems: json['total_items'],
        maxY: json['max_y'],
        loopY: json['loop_y'],
        formatedValue: json['formated_value'],
        totals: total);
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'image': image,
      'total_sales': totalSales,
      'total_items': totalItems,
      'max_y': maxY,
      'loop_y': loopY,
      'formated_value': formatedValue,
      'totals': totals,
    };
  }
}

class Totals {
  final String? date;
  final int? sales, items, salesFormated;

  Totals({this.date, this.sales, this.items, this.salesFormated});

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
        date: json['date'],
        sales: json['sales'],
        items: json['items'],
        salesFormated: json['sales_formated'].toInt());
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sales': sales,
      'items': items,
      'sale_formated': salesFormated
    };
  }
}
