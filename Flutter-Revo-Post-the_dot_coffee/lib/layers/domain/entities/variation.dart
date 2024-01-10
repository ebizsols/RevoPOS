import 'package:equatable/equatable.dart';

class Variation extends Equatable {
  final String? columnName;
  final String? value;

  const Variation({
    this.columnName,
    this.value,
  });

  @override
  List<Object?> get props => [
    columnName,
    value,
  ];
}