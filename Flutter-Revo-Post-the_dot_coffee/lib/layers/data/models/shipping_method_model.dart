import 'package:equatable/equatable.dart';

class ShippingMethodModel extends Equatable {
  final String? methodId;
  final String? methodTitle;
  final int? cost;

  ShippingMethodModel({this.methodId, this.methodTitle, this.cost});

  factory ShippingMethodModel.fromJson(Map<String, dynamic> json) {
    return ShippingMethodModel(
      methodId: json['method_id'],
      methodTitle: json['method_title'],
      cost: json['cost'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'method_id': methodId, 'method_title': methodTitle, 'cost': cost};
  }

  @override
  // TODO: implement props
  List<Object?> get props => [methodId, methodTitle, cost];
}
