import 'package:equatable/equatable.dart';

class Image extends Equatable {
  final int? id;
  final String? image;

  Image({this.id, this.image});

  @override
  List<Object?> get props => [id, image];
}
