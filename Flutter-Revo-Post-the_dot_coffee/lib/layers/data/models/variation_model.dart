import 'package:revo_pos/layers/domain/entities/status.dart';

class VariationModel extends Status {
  final String? columnName;
  final String? value;

  VariationModel({
    this.columnName,
    this.value
  });

  factory VariationModel.fromJson(Map<String, dynamic> json) {
    return VariationModel(
        columnName : json['column_name'],
        value: json['value']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'column_name' : columnName,
      'value' : value
    };
  }
}