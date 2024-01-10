import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? username;
  final Billing? billing;
  final Shipping? shipping;
  final Point? point;

  const Customer(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.username,
      this.billing,
      this.shipping,
      this.point});

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, username, billing, shipping, point];
}

class Billing extends Equatable {
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

  const Billing(
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

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        company,
        address1,
        address2,
        city,
        state,
        postcode,
        country,
        email,
        phone
      ];
}

class Shipping extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? company;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;

  const Shipping(
      {this.firstName,
      this.lastName,
      this.company,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.postcode,
      this.country});

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        company,
        address1,
        address2,
        city,
        state,
        postcode,
        country
      ];
}

class Point extends Equatable {
  final String? totalDiscount;
  final String? discountCoupon;
  final int? pointRedemption;

  const Point({
    this.totalDiscount,
    this.discountCoupon,
    this.pointRedemption,
  });

  @override
  List<Object?> get props => [
        totalDiscount,
        discountCoupon,
        pointRedemption,
      ];
}
