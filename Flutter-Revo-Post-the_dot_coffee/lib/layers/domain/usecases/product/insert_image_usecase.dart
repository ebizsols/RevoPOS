import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/repositories/product_repository.dart';

class InsertImageUsecase
    extends UseCase<Map<String, dynamic>, InsertImageParams> {
  final ProductRepository repository;

  InsertImageUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      InsertImageParams params) async {
    return await repository.insertImage(
        image: params.image!, title: params.title!);
  }
}

class InsertImageParams extends Equatable {
  final String? title;
  final String? image;

  const InsertImageParams({this.title, this.image});

  @override
  List<Object?> get props => [title, image];
}
