import 'package:revo_pos/core/utils/html_unescape.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';

class OrderModel extends Orders {
  final int? id, customerID;
  final String? orderKey,
      currency,
      status,
      dateCreated,
      dateModified,
      discountTotal,
      shippingTotal,
      total,
      totalTax,
      customerNote,
      paymentMethodTitle,
      paymentDescription,
      paymentUrl,
      transactionId,
      datePaid,
      dateCompleted,
      subTotalItems;

  final BillingModel? billing;
  final ShippingModel? shipping;
  final List<LineItemsModel>? lineItems;
  final List<ShippingLinesModel>? shippingLines;
  final List<CouponLinesModel>? couponLines;

  const OrderModel(
      {this.id,
      this.customerID,
      this.orderKey,
      this.currency,
      this.status,
      this.dateCreated,
      this.dateModified,
      this.discountTotal,
      this.shippingTotal,
      this.total,
      this.totalTax,
      this.customerNote,
      this.paymentMethodTitle,
      this.paymentDescription,
      this.transactionId,
      this.datePaid,
      this.paymentUrl,
      this.dateCompleted,
      this.billing,
      this.shipping,
      this.lineItems,
      this.shippingLines,
      this.couponLines,
      this.subTotalItems});

  Map<String, dynamic> toJson() {
    dynamic billing, shipping, lineItems, shippingLines, couponLines;
    if (this.billing != null) {
      billing = this.billing!.toJson();
    }
    if (this.shipping != null) {
      shipping = this.shipping!.toJson();
    }
    if (this.lineItems != null) {
      lineItems = this.lineItems!.map((v) => v.toJson()).toList();
    }
    if (this.shippingLines != null) {
      shippingLines = this.shippingLines!.map((v) => v.toJson()).toList();
    }
    if (this.couponLines != null) {
      couponLines = this.couponLines!.map((v) => v.toJson()).toList();
    }
    return {
      'id': id,
      'customer_id': customerID,
      'order_key': orderKey,
      'currency': currency,
      'status': status,
      'date_created': dateCreated,
      'date_modified': dateModified,
      'discount_total': discountTotal,
      'shipping_total': shippingTotal,
      'total': total,
      'total_tax': totalTax,
      'customer_note': customerNote,
      'payment_method_title': paymentMethodTitle,
      'payment_description': paymentDescription,
      'payment_url': paymentUrl,
      'transaction_id': transactionId,
      'date_paid': datePaid,
      'date_completed': dateCompleted,
      'billing': billing,
      'shipping': shipping,
      'line_items': lineItems,
      'shipping_lines': shippingLines,
      'coupon_lines': couponLines,
      'subtotal_items': subTotalItems
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    dynamic billing,
        shipping,
        lineItems,
        shippingLines,
        couponLines,
        paymentUrl,
        shippingTotal,
        total,
        totalTax,
        discountTotal;

    if (json['billing'] != null) {
      billing = BillingModel.fromJson(json['billing']);
    }
    if (json['shipping'] != null) {
      shipping = ShippingModel.fromJson(json['billing']);
    }
    if (json['meta_data'] != null) {
      json['meta_data'].forEach((v) {
        if (v['key'] == 'Xendit_invoice_url') {
          paymentUrl = v['value'];
        } else if (v['key'] == '_mt_payment_url') {
          paymentUrl =
              '${v['value']}#/${json['payment_method_title']!.toLowerCase()}';
        }
      });
    }
    if (json['shipping_total'] != null) {
      shippingTotal = json['shipping_total'];
    }
    if (json['total_tax'] != null) {
      totalTax = json['total_tax'];
    }
    if (json['line_items'] != null) {
      double tempTotal = 0;
      json['line_items'].forEach((v) {
        tempTotal += (v['price'] * v['quantity']);
      });
      lineItems = List.generate(json['line_items'].length,
          (index) => LineItemsModel.fromJson(json['line_items'][index]));
      tempTotal += double.parse(shippingTotal!);
      tempTotal += double.parse(totalTax!);
      total = tempTotal.toString();
    }
    if (json['shipping_lines'] != null) {
      shippingLines = List.generate(
          json['shipping_lines'].length,
          (index) =>
              ShippingLinesModel.fromJson(json['shipping_lines'][index]));
    }
    if (json['coupon_lines'] != null) {
      double totalDiscountTemp = 0;
      json['coupon_lines'].forEach((v) {
        totalDiscountTemp += double.parse(v['discount']);
      });
      couponLines = List.generate(json['coupon_lines'].length,
          (index) => CouponLinesModel.fromJson(json['coupon_lines'][index]));
      discountTotal = totalDiscountTemp.toString();
    }

    return OrderModel(
        id: json['id'],
        customerID: json['customer_id'],
        orderKey: json['order_key'],
        currency: json['currency'],
        status: json['status'],
        total: json['total'],
        totalTax: json['total_tax'],
        dateCreated: json['date_created'],
        dateModified: json['date_modified'],
        shippingTotal: shippingTotal,
        customerNote: json['customer_note'],
        paymentMethodTitle: json['payment_method_title'],
        paymentDescription: json['payment_description'],
        transactionId: json['transaction_id'],
        datePaid: json['date_paid'],
        dateCompleted: json['date_completed'],
        paymentUrl: paymentUrl,
        shippingLines: shippingLines,
        couponLines: couponLines,
        lineItems: lineItems,
        discountTotal: json['discount_total'],
        billing: billing,
        shipping: shipping,
        subTotalItems: json['subtotal_items']);
  }
}

class BillingModel extends Billing {
  final String? firstName,
      lastName,
      company,
      firstAddress,
      secondAddress,
      city,
      state,
      postCode,
      country,
      email,
      phone;

  const BillingModel(
      {this.firstName,
      this.lastName,
      this.company,
      this.firstAddress,
      this.secondAddress,
      this.city,
      this.state,
      this.postCode,
      this.country,
      this.email,
      this.phone});

  Map toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'company': company,
        'address_1': firstAddress,
        'address_2': secondAddress,
        'city': city,
        'state': state,
        'postcode': postCode,
        'country': country,
        'email': email,
        'phone': phone,
      };

  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
        firstName: json['first_name'],
        lastName: json['last_name'],
        company: json['company'],
        firstAddress: json['address_1'],
        secondAddress: json['address_2'],
        city: json['city'],
        state: json['state'],
        postCode: json['postcode'],
        country: json['country'],
        phone: json['phone'],
        email: json['email']);
  }
}

class ShippingModel extends Shipping {
  final String? firstName,
      lastName,
      company,
      firstAddress,
      secondAddress,
      city,
      state,
      postCode,
      country;

  const ShippingModel({
    this.firstName,
    this.lastName,
    this.company,
    this.firstAddress,
    this.secondAddress,
    this.city,
    this.state,
    this.postCode,
    this.country,
  });

  Map toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'company': company,
        'address_1': firstAddress,
        'address_2': secondAddress,
        'city': city,
        'state': state,
        'postcode': postCode,
        'country': country,
      };

  factory ShippingModel.fromJson(Map<String, dynamic> json) {
    return ShippingModel(
        firstName: json['first_name'],
        lastName: json['last_name'],
        company: json['company'],
        firstAddress: json['address_1'],
        secondAddress: json['address_2'],
        city: json['city'],
        state: json['state'],
        postCode: json['postcode'],
        country: json['country']);
  }
}

class LineItemsModel extends LineItems {
  final int? id, quantity, productId, variationId;
  final double? price;
  final String? productName, subTotal, subTotalTax, total, totalTax, sku, image;
  final List<MetaDataModel>? metaData;

  const LineItemsModel(
      {this.id,
      this.quantity,
      this.productId,
      this.price,
      this.productName,
      this.subTotal,
      this.subTotalTax,
      this.total,
      this.totalTax,
      this.sku,
      this.image,
      this.variationId,
      this.metaData});

  Map<String, dynamic> toJson() {
    dynamic metaData;
    if (this.metaData != null) {
      metaData = this.metaData!.map((v) => v.toJson()).toList();
    }
    return {
      'id': id,
      'name': productName,
      'product_id': productId,
      'quantity': quantity,
      'subtotal': subTotal,
      'subtotal_tax': subTotalTax,
      'total': total,
      'total_tax': totalTax,
      'sku': sku,
      'price': price,
      'image': image,
      'variation_id': variationId,
      'meta_data': metaData,
    };
  }

  factory LineItemsModel.fromJson(Map<String, dynamic> json) {
    dynamic metaData;
    if (json['meta_data'] != null) {
      metaData = List.generate(json['meta_data'].length,
          (index) => MetaDataModel.fromJson(json['meta_data'][index]));
    }
    dynamic price;
    if (json['price'] != null) {
      price = json['price'].toDouble();
    }

    return LineItemsModel(
        id: json['id'],
        productName: Unescape.htmlToString(json['name']),
        productId: json['product_id'],
        quantity: json['quantity'],
        subTotal: json['subtotal'],
        subTotalTax: json['subtotal_tax'],
        total: json['total'],
        totalTax: json['total_tax'],
        sku: json['sku'],
        price: price,
        image: json['image'] != null && json['image'] != false
            ? json['image']
            : "",
        variationId: json['variation_id'],
        metaData: metaData);
  }
}

class ShippingLinesModel extends ShippingLines {
  final int? id;
  final String? serviceName, total, totalTax, estDay;

  const ShippingLinesModel(
      {this.id, this.serviceName, this.total, this.totalTax, this.estDay});

  Map toJson() => {
        'id': id,
        'method_title': serviceName,
        'total': total,
        'total_tax': totalTax,
        'etd': estDay,
      };

  factory ShippingLinesModel.fromJson(Map<String, dynamic> json) {
    return ShippingLinesModel(
        id: json['id'],
        serviceName: json['method_title'],
        total: json['total'],
        totalTax: json['total_tax'],
        estDay: json['etd']);
  }
}

class CouponLinesModel extends CouponLines {
  final int? id;
  final String? code, discount, discountTax;

  const CouponLinesModel({this.id, this.code, this.discount, this.discountTax});

  Map toJson() => {
        'id': id,
        'code': code,
        'discount': discount,
        'discount_tax': discountTax,
      };

  factory CouponLinesModel.fromJson(Map<String, dynamic> json) {
    return CouponLinesModel(
        id: json['id'],
        code: json['code'],
        discount: json['discount'],
        discountTax: json['discount_tax']);
  }
}

class MetaDataModel extends MetaData {
  final int? id;
  final String? key, value;

  const MetaDataModel({this.id, this.key, this.value});

  Map toJson() => {
        'id': id,
        'key': key,
        'value': value,
      };

  factory MetaDataModel.fromJson(Map<String, dynamic> json) {
    return MetaDataModel(
        id: json['id'], key: json['key'], value: json['value']);
  }
}
