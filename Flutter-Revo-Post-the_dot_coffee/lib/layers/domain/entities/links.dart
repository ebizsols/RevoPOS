import 'package:equatable/equatable.dart';

class Links extends Equatable {
  final List<Self>? self;
  final List<Collection>? collection;

  Links({
    this.self,
    this.collection,
  });

  @override
  List<Object?> get props => [
    self,
    collection,
  ];
}

class Self extends Equatable {
  final String? href;

  Self({
    this.href,
  });

  @override
  List<Object?> get props => [
    href,
  ];
}

class Collection extends Equatable {
  final String? href;

  Collection({
    this.href,
  });

  @override
  List<Object?> get props => [
    href,
  ];
}