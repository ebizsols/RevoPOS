import 'package:revo_pos/layers/data/models/checkout_model.dart';

class PlaceOrderModel {
  int? id;
  List<LineItemsPlace>? lineItems;
  BillingModel? billingAddress;
  ShippingLinesModel? shippingLines;
  PaymentMethodModel? paymentMethod;
  List<Map<String, String>>? couponCode;
  String? orderNote;

  PlaceOrderModel(
      {this.id,
      this.lineItems,
      this.billingAddress,
      this.shippingLines,
      this.paymentMethod,
      this.couponCode,
      this.orderNote});

  Map<String, dynamic> toJson() {
    dynamic billing;
    if (billingAddress != null) {
      billing = billingAddress!.toJson();
    }
    dynamic shipping;
    if (shippingLines != null) {
      shipping = shippingLines!.toJson();
    }
    dynamic payment;
    if (paymentMethod != null) {
      payment = paymentMethod!.toJson();
    }
    dynamic lineItems;
    if (this.lineItems != null) {
      lineItems = this.lineItems!.map((v) => v.toJson()).toList();
    }

    return {
      'user_id': id,
      'line_items': lineItems,
      'billing_address': billing,
      'shipping_lines': shipping,
      'payment_method': payment,
      'coupon_lines': couponCode,
      'order_notes': orderNote
    };
  }

  PlaceOrderModel.fromJson(Map json) {
    id = json['user_id'];
    if (json['line_items'] != null) {
      json['line_items'].forEach((v) {
        lineItems?.add(LineItemsPlace.fromJson(v));
      });
    }
    if (json['billing_address'] != null) {
      billingAddress = BillingModel.fromJson(json['billing_address']);
    }
    if (json['shipping_lines'] != null) {
      shippingLines = ShippingLinesModel.fromJson(json['shipping_lines']);
    }
    if (json['payment_method'] != null) {
      paymentMethod = PaymentMethodModel.fromJson(json['payment_method']);
    }
    couponCode = json['coupon_lines'];
    orderNote = json['order_notes'];
  }
}

class LineItemsPlace {
  int? productId, quantity, variationId;
  LineItemsPlace({this.productId, this.quantity, this.variationId});
  Map toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'variation_id': variationId
      };
  LineItemsPlace.fromJson(Map json) {
    productId = json['product_id'];
    quantity = json['quantity'];
    variationId = json['variation_id'];
  }
}

class ShippingLinesModel {
  String? methodId, methodTitle;
  int? cost;

  ShippingLinesModel({this.methodId, this.methodTitle, this.cost});

  Map toJson() =>
      {'method_id': methodId, 'method_title': methodTitle, 'cost': cost};

  ShippingLinesModel.fromJson(Map json) {
    methodId = json['method_id'];
    methodTitle = json['method_title'];
    cost = json['cost'];
  }
}

class PaymentMethodModel {
  String? id, title;

  PaymentMethodModel({this.id, this.title});

  Map toJson() => {'id': id, 'title': title};

  PaymentMethodModel.fromJson(Map json) {
    id = json['id'];
    title = json['title'];
  }
}
