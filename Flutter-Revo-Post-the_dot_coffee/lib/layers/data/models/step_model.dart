import 'package:revo_pos/layers/domain/entities/step.dart';

class StepModel extends Step {
  final String? title, slug;

  StepModel({this.title, this.slug});

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(title: json['title'], slug: json['slug']);
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'slug': slug};
  }
}
