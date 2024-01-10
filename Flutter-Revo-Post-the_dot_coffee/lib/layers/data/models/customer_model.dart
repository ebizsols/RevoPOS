import 'package:revo_pos/layers/domain/entities/customer.dart';

class CustomerModel extends Customer {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? username;
  final BillingModel? billing;
  final ShippingModel? shipping;
  final PointModel? point;

  const CustomerModel(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.password,
      this.username,
      this.billing,
      this.shipping,
      this.point});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    dynamic billing;
    if (json['billing'] != null) {
      billing = BillingModel.fromJson(json['billing']);
    }
    dynamic shipping;
    if (json['shipping'] != null) {
      shipping = ShippingModel.fromJson(json['shipping']);
    }
    dynamic point;
    if (json['point'] != null) {
      point = PointModel.fromJson(json['point']);
    }
    return CustomerModel(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        password: "123",
        username: json['username'],
        shipping: shipping,
        billing: billing,
        point: point);
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
    dynamic point;
    if (this.point != null) {
      point = this.point!.toJson();
    }
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'username': username,
      'billing': billing,
      'shipping': shipping,
      'point': point
    };
  }
}

class BillingModel extends Billing {
  final String? firstName;
  final String? lastName;
  final String? company;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;
  final String? email;
  final String? phone;

  const BillingModel(
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
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      company: json['company'],
      address1: json['address_1'],
      address2: json['address_2'],
      city: json['city'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
      phone: json['phone'],
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
      'email': email,
      'phone': phone
    };
  }
}

class ShippingModel extends Shipping {
  final String? firstName;
  final String? lastName;
  final String? company;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;

  const ShippingModel(
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

class PointModel extends Point {
  final int? pointRedemption;
  final String? totalDiscount;
  final String? discountCoupon;

  const PointModel({
    this.pointRedemption,
    this.totalDiscount,
    this.discountCoupon,
  });

  factory PointModel.fromJson(Map<String, dynamic> json) {
    return PointModel(
      pointRedemption: json['point_redemption'],
      totalDiscount: json['total_discount'],
      discountCoupon: json['discount_coupon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'point_redemption': pointRedemption,
      'total_discount': totalDiscount,
      'discount_coupon': discountCoupon,
    };
  }
}
