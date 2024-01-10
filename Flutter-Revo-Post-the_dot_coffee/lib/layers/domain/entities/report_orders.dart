import 'package:equatable/equatable.dart';
import 'package:revo_pos/layers/data/models/report_orders_model.dart';

class ReportOrders extends Equatable {
  final String? totalSales,
      avgGross,
      netSales,
      avgSales,
      totalTax,
      totalShipping,
      totalDiscount,
      totalGroupedBy;
  int? totalOrders,
      totalItems,
      totalRefunds,
      totalCustomer,
      refundOrderItems,
      totalRefundOrders,
      maxY,
      loopY,
      loopYItem,
      formatedValue;
  final List<Totals>? totals;

  ReportOrders(
      {this.totalSales,
      this.avgGross,
      this.netSales,
      this.avgSales,
      this.totalTax,
      this.totalShipping,
      this.totalDiscount,
      this.totalGroupedBy,
      this.totalOrders,
      this.totalItems,
      this.totalRefunds,
      this.refundOrderItems,
      this.totalRefundOrders,
      this.totalCustomer,
      this.maxY,
      this.loopY,
      this.loopYItem,
      this.formatedValue,
      this.totals});

  @override
  List<Object?> get props => [
        totalSales,
        avgGross,
        netSales,
        avgSales,
        totalTax,
        totalShipping,
        totalDiscount,
        totalGroupedBy,
        totalOrders,
        totalItems,
        totalRefunds,
        refundOrderItems,
        totalRefundOrders,
        totalCustomer,
        maxY,
        loopY,
        loopYItem,
        formatedValue,
        totals
      ];
}
