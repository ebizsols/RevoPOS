import 'package:equatable/equatable.dart';

class Step extends Equatable {
  final String? title, slug;

  Step({this.title, this.slug});
  @override
  List<Object?> get props => [title, slug];
}
