import 'package:revo_pos/layers/domain/entities/report_orders.dart';

class ReportOrdersModel extends ReportOrders {
  final String? totalSales,
      avgGross,
      netSales,
      avgSales,
      totalTax,
      totalShipping,
      totalDiscount,
      totalGroupedBy;
  final int? totalOrders,
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

  ReportOrdersModel(
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
      this.totalCustomer,
      this.refundOrderItems,
      this.totalRefundOrders,
      this.maxY,
      this.loopY,
      this.loopYItem,
      this.formatedValue,
      this.totals});

  factory ReportOrdersModel.fromJson(Map<String, dynamic> json) {
    var total;
    if (json['totals'] != null) {
      total = List.generate(json['totals'].length,
          (index) => Totals.fromJson(json['totals'][index]));
    }
    return ReportOrdersModel(
        totalSales: json['total_sales'],
        avgGross: json['average_gross'],
        netSales: json['net_sales'],
        avgSales: json['average_sales'],
        totalOrders: json['total_orders'],
        totalItems: json['total_items'],
        totalTax: json['total_tax'],
        totalShipping: json['total_shipping'],
        totalRefunds: json['total_refunds'],
        refundOrderItems: json['refunded_order_items'],
        totalRefundOrders: json['total_refunded_orders'],
        totalDiscount: json['total_discount'],
        totalGroupedBy: json['totals_grouped_by'],
        maxY: json['max_y'],
        loopY: json['loop_y'],
        loopYItem: json['loop_y_item'],
        formatedValue: json['formated_value'],
        totals: total,
        totalCustomer: json['total_customers']);
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sales': totalSales,
      'average_gross': avgGross,
      'net_sales': netSales,
      'average_sales': avgSales,
      'total_orders': totalOrders,
      'total_items': totalItems,
      'total_tax': totalTax,
      'total_shipping': totalShipping,
      'total_refunds': totalRefunds,
      'refunded_order_items': refundOrderItems,
      'total_refunded_orders': totalRefundOrders,
      'total_discount': totalDiscount,
      'totals_grouped_by': totalGroupedBy,
      'max_y': maxY,
      'loop_y': loopY,
      'loop_y_item': loopYItem,
      'formated_value': formatedValue,
      'totals': totals,
      'total_customers': totalCustomer
    };
  }
}

class Totals {
  final String? sales, tax, shipping, discount, date;
  final int? orders, items, customers;
  final num? salesFormated,
      taxFormated,
      shippingFormated,
      discountFormated,
      netSales,
      netSalesFormated;

  Totals(
      {this.sales,
      this.tax,
      this.shipping,
      this.discount,
      this.date,
      this.orders,
      this.items,
      this.customers,
      this.salesFormated,
      this.taxFormated,
      this.shippingFormated,
      this.discountFormated,
      this.netSales,
      this.netSalesFormated});

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
        sales: json['sales'],
        orders: json['orders'],
        items: json['items'],
        tax: json['tax'],
        shipping: json['shipping'],
        discount: json['discount'],
        customers: json['customers'],
        date: json['date'],
        salesFormated: json['sales_formated'],
        taxFormated: json['tax_formated'],
        shippingFormated: json['shipping_formated'],
        discountFormated: json['discount_formated'],
        netSales: json['net_sales'],
        netSalesFormated: json['net_sales_formated']);
  }

  Map<String, dynamic> toJson() {
    return {
      'sales': sales,
      'orders': orders,
      'items': items,
      'tax': tax,
      'shipping': shipping,
      'discount': discount,
      'customers': customers,
      'date': date,
      'sales_formated': salesFormated,
      'tax_formated': taxFormated,
      'shipping_formated': shippingFormated,
      'discount_formated': discountFormated,
      'net_sales': netSales,
      'net_sales_formated': netSalesFormated
    };
  }
}
