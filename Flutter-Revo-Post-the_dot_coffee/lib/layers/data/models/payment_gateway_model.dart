import 'package:revo_pos/layers/domain/entities/payment_gateway.dart';

class PaymentGatewayModel extends PaymentGateway {
  final String? id;
  final String? title;
  final String? description;
  final dynamic order;
  final bool? enabled;
  final String? methodTitle;
  final String? methodDescription;
  final List<dynamic>? methodSupports;
  final PaymentSettingsModel? settings;

  PaymentGatewayModel(
      {this.id,
      this.title,
      this.description,
      this.order,
      this.enabled,
      this.methodTitle,
      this.methodDescription,
      this.methodSupports,
      this.settings});

  factory PaymentGatewayModel.fromJson(Map<String, dynamic> json) {
    dynamic settings;
    // if (json['settings'] != null) {
    //   settings = PaymentSettingsModel.fromJson(json['settings']);
    // }

    return PaymentGatewayModel(
        id: json['id'],
        description: json['description'],
        order: json['order'],
        enabled: json['enabled'],
        methodTitle: json['method_title'],
        methodDescription: json['method_description'],
        methodSupports: json['method_supports'],
        title: json['title'],
        settings: settings);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['order'] = order;
    data['enabled'] = enabled;
    data['method_title'] = methodTitle;
    data['method_description'] = methodDescription;
    data['method_supports'] = methodSupports;
    if (settings != null) {
      data['settings'] = settings!.toJson();
    }
    return data;
  }
}

class PaymentSettingsModel extends PaymentSettings {
  final TitleModel? title;
  final TitleModel? instructions;

  PaymentSettingsModel({this.title, this.instructions});

  factory PaymentSettingsModel.fromJson(Map<String, dynamic> json) {
    dynamic title, instructions;
    if (json['title'] != null) {
      title = TitleModel.fromJson(json['title']);
    }
    if (json['instructions'] != null) {
      title = TitleModel.fromJson(json['instructions']);
    }

    return PaymentSettingsModel(title: title, instructions: instructions);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (title != null) {
      data['title'] = title!.toJson();
    }
    if (instructions != null) {
      data['instructions'] = instructions!.toJson();
    }
    return data;
  }
}

class TitleModel extends Title {
  final String? id;
  final String? label;
  final String? description;
  final String? type;
  final String? value;
  final String? tip;
  final String? placeholder;

  TitleModel(
      {this.id,
      this.label,
      this.description,
      this.type,
      this.value,
      this.tip,
      this.placeholder});

  factory TitleModel.fromJson(Map<String, dynamic> json) {
    return TitleModel(
      id: json['id'],
      description: json['description'],
      label: json['label'],
      placeholder: json['placeholder'],
      tip: json['tip'],
      type: json['type'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['label'] = label;
    data['description'] = description;
    data['type'] = type;
    data['value'] = value;
    data['tip'] = tip;
    data['placeholder'] = placeholder;
    return data;
  }
}
