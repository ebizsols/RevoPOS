import 'package:equatable/equatable.dart';

class PaymentGateway extends Equatable {
  final String? id;
  final String? title;
  final String? description;
  final dynamic order;
  final bool? enabled;
  final String? methodTitle;
  final String? methodDescription;
  final List<dynamic>? methodSupports;
  final PaymentSettings? settings;

  PaymentGateway(
      {this.id,
      this.title,
      this.description,
      this.order,
      this.enabled,
      this.methodTitle,
      this.methodDescription,
      this.methodSupports,
      this.settings});

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        order,
        enabled,
        methodTitle,
        methodDescription,
        methodSupports,
        settings
      ];
}

class PaymentSettings extends Equatable {
  final Title? title;
  final Title? instructions;

  PaymentSettings({this.title, this.instructions});

  @override
  List<Object?> get props => [title, instructions];
}

class Title extends Equatable {
  final String? id;
  final String? label;
  final String? description;
  final String? type;
  final String? value;
  final String? tip;
  final String? placeholder;

  Title(
      {this.id,
      this.label,
      this.description,
      this.type,
      this.value,
      this.tip,
      this.placeholder});

  @override
  List<Object?> get props =>
      [id, label, description, type, value, tip, placeholder];
}
