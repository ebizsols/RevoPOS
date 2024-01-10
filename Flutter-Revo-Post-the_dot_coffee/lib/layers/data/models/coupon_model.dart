import 'package:equatable/equatable.dart';

class CouponModel extends Equatable {
  final int? id;
  final String? code;
  final String? dateExpires;
  final String? description;
  final String? discountType;
  final String? amount;

  const CouponModel(
      {this.id,
      this.code,
      this.dateExpires,
      this.description,
      this.discountType,
      this.amount});

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      code: json['code'],
      dateExpires: json['date_expires'],
      description: json['description'],
      discountType: json['discount_type'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'date_expires': dateExpires,
      'description': description,
      'discount_type': discountType,
      'amount': amount
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [id, code, dateExpires, description, discountType, amount];
}

class CouponsModel extends Equatable {
  final String? code;
  final String? message;

  const CouponsModel({this.code, this.message});

  factory CouponsModel.fromJson(Map<String, dynamic> json) {
    return CouponsModel(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message};
  }

  @override
  // TODO: implement props
  List<Object?> get props => [code, message];
}
