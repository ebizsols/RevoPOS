import 'package:revo_pos/layers/data/models/product_model.dart';

class CheckoutModel {
  int? customerId;
  String? paymentMethod;
  String? paymentMethodTitle;
  bool? setPaid;
  BillingModel? billing;
  ShippingModel? shipping;
  List<LineItemsModel>? lineItems;
  List<ShippingLinesModel>? shippingLines;
  List<CouponLinesModel>? couponLines;
  List<ProductModel>? listProduct;
  double? totalPrice;
  double? totalDisc;
  double? grandTotal;
  String? token;
  String? customerNote;
  String? status;

  CheckoutModel(
      {this.customerId,
      this.paymentMethod,
      this.paymentMethodTitle,
      this.setPaid,
      this.billing,
      this.shipping,
      this.lineItems,
      this.shippingLines,
      this.couponLines,
      this.listProduct,
      this.totalPrice,
      this.totalDisc,
      this.grandTotal,
      this.token,
      this.customerNote,
      this.status});

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    dynamic billing;
    if (json['billing'] != null) {
      billing = BillingModel.fromJson(json['billing']);
    }
    dynamic shipping;
    if (json['shipping'] != null) {
      shipping = ShippingModel.fromJson(json['shipping']);
    }
    dynamic lineItems;
    if (json['line_items'] != null) {
      lineItems = List.generate(json['line_items'].length,
          (index) => LineItemsModel.fromJson(json['line_items'][index]));
    }
    dynamic shippingLines;
    if (json['shipping_lines'] != null) {
      shippingLines = List.generate(
          json['shipping_lines'].length,
          (index) =>
              ShippingLinesModel.fromJson(json['shipping_lines'][index]));
    }
    dynamic couponLines;
    if (json['coupon_lines'] != null) {
      couponLines = List.generate(json['coupon_lines'].length,
          (index) => CouponLinesModel.fromJson(json['coupon_lines'][index]));
    }
    dynamic listProduct;
    if (json['list_product'] != null) {
      listProduct = List.generate(json['list_product'].length,
          (index) => ProductModel.fromJson(json['list_product'][index]));
    }

    return CheckoutModel(
        customerId: json['customer_id'],
        paymentMethod: json['payment_method'],
        paymentMethodTitle: json['payment_method_title'],
        setPaid: json['set_paid'],
        shipping: shipping,
        billing: billing,
        lineItems: lineItems,
        shippingLines: shippingLines,
        couponLines: couponLines,
        listProduct: listProduct,
        totalPrice: json['total_price'],
        totalDisc: json['total_disc'],
        grandTotal: json['grand_total'],
        token: json['token'],
        customerNote: json['customer_note'],
        status: json['status']);
  }

  Map<String, dynamic> toJson() {
    dynamic billing;
    if (this.billing != null) {
      billing = this.billing!.toJson();
    }
    dynamic shipping;
    if (this.shipping != null) {
      shipping = this.shipping!.toJson();
    }
    dynamic lineItems;
    if (this.lineItems != null) {
      lineItems = this.lineItems!.map((v) => v.toJson()).toList();
    }
    dynamic shippingLines;
    if (this.shippingLines != null) {
      shippingLines = this.shippingLines!.map((v) => v.toJson()).toList();
    }
    dynamic couponLines;
    if (this.couponLines != null) {
      couponLines = this.couponLines!.map((v) => v.toJson()).toList();
    }
    dynamic listProduct;
    if (this.listProduct != null) {
      listProduct = this.listProduct!.map((v) => v.toJson()).toList();
    }
    return {
      'customer_id': customerId,
      'payment_method': paymentMethod,
      'payment_method_title': paymentMethodTitle,
      'set_paid': setPaid,
      'billing': billing,
      'shipping': shipping,
      'line_items': lineItems,
      'shipping_lines': shippingLines,
      'coupon_lines': couponLines,
      'list_product': listProduct,
      'total_price': totalPrice,
      'total_disc': totalDisc,
      'grand_total': grandTotal,
      'token': token,
      'customer_note': customerNote,
      'status': status
    };
  }
}

class BillingModel {
  String? firstName;
  String? lastName;
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? postcode;
  String? country;
  String? email;
  String? phone;

  BillingModel(
      {this.firstName,
      this.lastName,
      this.company,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.postcode,
      this.country,
      this.email,
      this.phone});

  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
      firstName: json['first_name'] == "" ? "-" : json['first_name'],
      lastName: json['last_name'] == "" ? "-" : json['last_name'],
      email: json['email'] == "" ? "-" : json['email'],
      company: json['company'],
      address1: json['address_1'] == "" ? "-" : json['address_1'],
      address2: json['address_2'],
      city: json['city'] == "" ? "-" : json['city'],
      state: json['state'] == "" ? "-" : json['state'],
      postcode: json['postcode'] == "" ? "-" : json['postcode'],
      country: json['country'] == "" ? "-" : json['country'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName == "" ? "-" : firstName,
      'last_name': lastName == "" ? "-" : lastName,
      'company': company,
      'address_1': address1 == "" ? "-" : address1,
      'address_2': address2,
      'city': city == "" ? "-" : city,
      'state': state == "" ? "-" : state,
      'postcode': postcode == "" ? "-" : postcode,
      'country': country == "" ? "-" : country,
      'email': email == "" ? "-" : email,
      'phone': phone
    };
  }
}

class ShippingModel {
  String? firstName;
  String? lastName;
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? postcode;
  String? country;

  ShippingModel(
      {this.firstName,
      this.lastName,
      this.company,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.postcode,
      this.country});

  factory ShippingModel.fromJson(Map<String, dynamic> json) {
    return ShippingModel(
      firstName: json['first_name'],
      lastName: json['last_name'],
      company: json['company'],
      address1: json['address_1'],
      address2: json['address_2'],
      city: json['city'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'company': company,
      'address_1': address1,
      'address_2': address2,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
    };
  }
}

class LineItemsModel {
  int? productId;
  int? quantity;
  int? variationId;

  LineItemsModel({this.productId, this.quantity, this.variationId});

  factory LineItemsModel.fromJson(Map<String, dynamic> json) {
    return LineItemsModel(
      productId: json['product_id'],
      quantity: json['quantity'],
      variationId: json['variation_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'variation_id': variationId
    };
  }
}

class ShippingLinesModel {
  String? methodId;
  String? methodTitle;
  String? total;

  ShippingLinesModel({this.methodId, this.methodTitle, this.total});

  factory ShippingLinesModel.fromJson(Map<String, dynamic> json) {
    return ShippingLinesModel(
      methodId: json['method_id'],
      methodTitle: json['method_title'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'method_id': methodId, 'method_title': methodTitle, 'total': total};
  }
}

class CouponLinesModel {
  String? code;

  CouponLinesModel({this.code});

  factory CouponLinesModel.fromJson(Map<String, dynamic> json) {
    return CouponLinesModel(
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code};
  }
}

class OrderPrint {
  int? idOrder, discount;
  String? date, total, totalTax;
  List<ShippingLinesModel>? shippingLines = [];
  BillingModel? billing;
  List<LineItemsModelPrint>? lineItem = [];

  OrderPrint(
      {this.idOrder,
      this.date,
      this.billing,
      this.discount,
      this.shippingLines,
      this.total,
      this.lineItem,
      this.totalTax});

  Map toJson() => {
        'id': idOrder,
        'date': date,
        'discount': discount,
        'total': total,
        'shippingLines': shippingLines,
        'billing': billing,
        'line_items': lineItem,
        'total_tax': totalTax
      };

  OrderPrint.friomJson(Map json) {
    idOrder = json['id'];
    date = json['date_created'];
    discount = double.parse(json['discount_total'].toString()).toInt();
    total = json['total'];
    totalTax = json['total_tax'];
    if (json['billing'] != null) {
      billing = BillingModel.fromJson(json['billing']);
    }
    if (json['shipping_lines'] != null) {
      shippingLines = List<ShippingLinesModel>.empty(growable: true);
      json['shipping_lines'].forEach((v) {
        shippingLines?.add(ShippingLinesModel.fromJson(v));
      });
    }
    if (json['line_items'] != null) {
      lineItem = List<LineItemsModelPrint>.empty(growable: true);
      json['line_items'].forEach((v) {
        lineItem?.add(LineItemsModelPrint.fromJson(v));
      });
    }
  }
}

class CheckoutPrint {
  int? idOrder;
  String? date;
  int? customerId;
  String? paymentMethod;
  String? paymentMethodTitle;
  bool? setPaid;
  BillingModel? billing;
  ShippingModel? shipping;
  List<LineItemsModel>? lineItems;
  List<ShippingLinesModel>? shippingLines;
  List<CouponLinesModel>? couponLines;
  List<ProductModel>? listProduct;
  double? totalPrice;
  double? totalDisc;
  double? grandTotal;
  String? token;
  String? customerNote;

  CheckoutPrint(
      {this.customerId,
      this.idOrder,
      this.date,
      this.paymentMethod,
      this.paymentMethodTitle,
      this.setPaid,
      this.billing,
      this.shipping,
      this.lineItems,
      this.shippingLines,
      this.couponLines,
      this.listProduct,
      this.totalPrice,
      this.totalDisc,
      this.grandTotal,
      this.token,
      this.customerNote});

  factory CheckoutPrint.fromJson(Map<String, dynamic> json) {
    dynamic billing;
    if (json['billing'] != null) {
      billing = BillingModel.fromJson(json['billing']);
    }
    dynamic shipping;
    if (json['shipping'] != null) {
      shipping = ShippingModel.fromJson(json['shipping']);
    }
    dynamic lineItems;
    if (json['line_items'] != null) {
      lineItems = List.generate(json['line_items'].length,
          (index) => LineItemsModel.fromJson(json['line_items'][index]));
    }
    dynamic shippingLines;
    if (json['shipping_lines'] != null) {
      shippingLines = List.generate(
          json['shipping_lines'].length,
          (index) =>
              ShippingLinesModel.fromJson(json['shipping_lines'][index]));
    }
    dynamic couponLines;
    if (json['coupon_lines'] != null) {
      couponLines = List.generate(json['coupon_lines'].length,
          (index) => CouponLinesModel.fromJson(json['coupon_lines'][index]));
    }
    dynamic listProduct;
    if (json['list_product'] != null) {
      listProduct = List.generate(json['list_product'].length,
          (index) => ProductModel.fromJson(json['list_product'][index]));
    }

    return CheckoutPrint(
        date: json['date_created'],
        idOrder: json['id'],
        customerId: json['customer_id'],
        paymentMethod: json['payment_method'],
        paymentMethodTitle: json['payment_method_title'],
        setPaid: json['set_paid'],
        shipping: shipping,
        billing: billing,
        lineItems: lineItems,
        shippingLines: shippingLines,
        couponLines: couponLines,
        listProduct: listProduct,
        totalPrice: json['total_price'],
        totalDisc: json['total_disc'],
        grandTotal: json['grand_total'],
        token: json['token'],
        customerNote: json['customer_note']);
  }

  Map<String, dynamic> toJson() {
    dynamic billing;
    if (this.billing != null) {
      billing = this.billing!.toJson();
    }
    dynamic shipping;
    if (this.shipping != null) {
      shipping = this.shipping!.toJson();
    }
    dynamic lineItems;
    if (this.lineItems != null) {
      lineItems = this.lineItems!.map((v) => v.toJson()).toList();
    }
    dynamic shippingLines;
    if (this.shippingLines != null) {
      shippingLines = this.shippingLines!.map((v) => v.toJson()).toList();
    }
    dynamic couponLines;
    if (this.couponLines != null) {
      couponLines = this.couponLines!.map((v) => v.toJson()).toList();
    }
    dynamic listProduct;
    if (this.listProduct != null) {
      listProduct = this.listProduct!.map((v) => v.toJson()).toList();
    }
    return {
      'customer_id': customerId,
      'payment_method': paymentMethod,
      'payment_method_title': paymentMethodTitle,
      'set_paid': setPaid,
      'billing': billing,
      'shipping': shipping,
      'line_items': lineItems,
      'shipping_lines': shippingLines,
      'coupon_lines': couponLines,
      'list_product': listProduct,
      'total_price': totalPrice,
      'total_disc': totalDisc,
      'grand_total': grandTotal,
      'token': token,
      'customer_note': customerNote
    };
  }
}

class LineItemsModelPrint {
  String? name;
  int? qty;
  double? price;

  LineItemsModelPrint({this.name, this.price, this.qty});

  factory LineItemsModelPrint.fromJson(Map<String, dynamic> json) {
    return LineItemsModelPrint(
      name: json['name'],
      qty: json['quantity'],
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': qty,
      'name': name,
      'price': price,
    };
  }
}
