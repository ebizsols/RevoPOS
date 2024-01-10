import 'package:equatable/equatable.dart';
import 'package:revo_pos/layers/data/models/report_orders_coupon_model.dart';

class ReportOrdersCoupon extends Equatable {
  final int? couponUsed, maxY, loopY, formatedValue, loopYitem;
  final String? totalDiscount, couponCode;
  final List<Totals>? totals;

  ReportOrdersCoupon(
      {this.totalDiscount,
      this.couponUsed,
      this.couponCode,
      this.maxY,
      this.loopY,
      this.formatedValue,
      this.totals,
      this.loopYitem});

  @override
  List<Object?> get props => [
        totalDiscount,
        couponUsed,
        couponCode,
        maxY,
        loopY,
        formatedValue,
        totals,
        loopYitem
      ];
}
