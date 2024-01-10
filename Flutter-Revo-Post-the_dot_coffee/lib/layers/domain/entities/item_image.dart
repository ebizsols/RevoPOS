import 'package:equatable/equatable.dart';

class ItemImage extends Equatable {
  final int? id;
  final String? dateCreated;
  final String? dateCreatedGmt;
  final String? dateModified;
  final String? dateModifiedGmt;
  final String? src;
  final String? name;
  final String? alt;

  ItemImage({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.src,
    this.name,
    this.alt,
  });

  @override
  List<Object?> get props => [
    id,
    dateCreated,
    dateCreatedGmt,
    dateModified,
    dateModifiedGmt,
    src,
    name,
    alt,
  ];
}