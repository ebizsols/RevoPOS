import 'package:equatable/equatable.dart';

class Orders extends Equatable {
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

  final Billing? billing;
  final Shipping? shipping;
  final List<LineItems>? lineItems;
  final List<ShippingLines>? shippingLines;
  final List<CouponLines>? couponLines;

  @override
  List<Object?> get props => [
        id,
        customerID,
        orderKey,
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
        billing,
        shipping,
        shippingLines,
        lineItems,
        couponLines,
        subTotalItems
      ];

  const Orders(
      {this.id,
      this.customerID,
      this.orderKey,
      this.currency,
      this.status,
      this.dateCreated,
      this.dateModified,
      this.shippingTotal,
      this.total,
      this.totalTax,
      this.customerNote,
      this.paymentMethodTitle,
      this.paymentDescription,
      this.paymentUrl,
      this.transactionId,
      this.datePaid,
      this.dateCompleted,
      this.billing,
      this.shipping,
      this.discountTotal,
      this.lineItems,
      this.shippingLines,
      this.couponLines,
      this.subTotalItems});
}

class Billing extends Equatable {
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

  const Billing(
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

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        company,
        firstAddress,
        secondAddress,
        city,
        state,
        postCode,
        country,
        email,
        phone
      ];
}

class Shipping extends Equatable {
  final String? firstName,
      lastName,
      company,
      firstAddress,
      secondAddress,
      city,
      state,
      postCode,
      country;

  const Shipping(
      {this.firstName,
      this.lastName,
      this.company,
      this.firstAddress,
      this.secondAddress,
      this.city,
      this.state,
      this.postCode,
      this.country});

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        company,
        firstAddress,
        secondAddress,
        city,
        state,
        postCode,
        country
      ];
}

class LineItems extends Equatable {
  final int? id, quantity, productId, variationId;
  final double? price;
  final String? productName, subTotal, subTotalTax, total, totalTax, sku, image;
  final List<MetaData>? metaData;

  const LineItems(
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

  @override
  List<Object?> get props => [
        id,
        quantity,
        productId,
        variationId,
        price,
        productName,
        subTotal,
        subTotalTax,
        total,
        totalTax,
        sku,
        image,
        metaData
      ];
}

class ShippingLines extends Equatable {
  final int? id;
  final String? serviceName, total, totalTax, estDay;

  const ShippingLines(
      {this.id, this.serviceName, this.total, this.totalTax, this.estDay});

  @override
  List<Object?> get props => [id, serviceName, total, totalTax, estDay];
}

class CouponLines extends Equatable {
  final int? id;
  final String? code, discount, discountTax;

  const CouponLines({this.id, this.code, this.discount, this.discountTax});

  @override
  List<Object?> get props => [id, code, discount, discountTax];
}

class MetaData extends Equatable {
  final int? id;
  final String? key, value;

  const MetaData({this.id, this.key, this.value});

  @override
  List<Object?> get props => [id, key, value];
}
