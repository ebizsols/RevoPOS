import 'package:equatable/equatable.dart';

class SettingModel extends Equatable {
  final String? id;
  final String? label;
  final String? description;
  final String? type;
  final String? defaultValue;
  final Map<String, dynamic>? options;
  final String? tip;
  final dynamic value;
  final String? symbol;

  const SettingModel(
      {this.id,
      this.label,
      this.description,
      this.type,
      this.defaultValue,
      this.options,
      this.tip,
      this.value,
      this.symbol});

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    dynamic options;
    String _temp;
    String symbol = '';
    String start = "(";
    String end = ")";

    if (json['options'] != null) {
      options = json['options'];
      if (json['id'] == 'woocommerce_currency'){
        int startIndex;
        _temp = json['options']['${json['value']}'];
        if (json['value'] == 'USD'){
          start = "(&";
          startIndex = _temp.indexOf(start) - 1;
        } else {
          startIndex = _temp.indexOf(start);
        }
        final endIndex = _temp.indexOf(end, startIndex + start.length);
        symbol = _temp.substring(startIndex + start.length, endIndex);
      }
    }

    return SettingModel(
      id: json['id'],
      label: json['label'],
      description: json['description'],
      type: json['type'],
      defaultValue: json['default'],
      options: options,
      tip: json['tip'],
      value: json['value'],
      symbol: symbol,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'type': type,
      'default': defaultValue,
      'options': options,
      'tip': tip,
      'value': value,
      'symbol': symbol,
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [id, label, description, type, defaultValue, options, tip, value, symbol];
}
