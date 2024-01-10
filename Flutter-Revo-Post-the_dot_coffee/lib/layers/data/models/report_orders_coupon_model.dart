import 'package:revo_pos/layers/domain/entities/report_orders_coupon.dart';

class ReportOrdersCouponModel extends ReportOrdersCoupon {
  final String? totalDiscount, couponCode;
  final int? couponUsed, maxY, loopY, formatedValue, loopYitem;
  final List<Totals>? totals;

  ReportOrdersCouponModel(
      {this.totalDiscount,
      this.couponCode,
      this.couponUsed,
      this.maxY,
      this.loopY,
      this.formatedValue,
      this.totals,
      this.loopYitem});

  factory ReportOrdersCouponModel.fromJson(Map<String, dynamic> json) {
    var total;
    if (json['totals'] != null) {
      total = List.generate(json['totals'].length,
          (index) => Totals.fromJson(json['totals'][index]));
    }
    return ReportOrdersCouponModel(
        totalDiscount: json['total_discount'].toString(),
        couponUsed: json['coupons_used'],
        couponCode: json['coupon_code'],
        maxY: json['max_y'],
        loopY: json['loop_y'],
        formatedValue: json['formated_value'],
        totals: total,
        loopYitem: json['loop_y_item']);
  }

  Map<String, dynamic> toJson() {
    return {
      'total_discount': totalDiscount,
      'coupons_used': couponUsed,
      'coupon_code': couponCode,
      'max_y': maxY,
      'loop_y': loopY,
      'formated_value': formatedValue,
      'totals': totals,
      'loop_y_item': loopYitem
    };
  }
}

class Totals {
  final String? date;
  final num? totalDiscount, totalUsed, totalDiscountFormated;

  Totals(
      {this.date,
      this.totalDiscount,
      this.totalUsed,
      this.totalDiscountFormated});

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
        date: json['date'],
        totalDiscount: json['total_discount'],
        totalUsed: json['total_used'],
        totalDiscountFormated: json['total_discount_formated']);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total_discount': totalDiscount,
      'total_used': totalUsed,
      'total_discount_formated': totalDiscountFormated
    };
  }
}
