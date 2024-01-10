import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/domain/repositories/product_repository.dart';

class GetAttributeUsecase extends UseCase<List<Attribute>, GetAttributeParams> {
  final ProductRepository repository;

  GetAttributeUsecase(this.repository);

  @override
  Future<Either<Failure, List<Attribute>>> call(
      GetAttributeParams params) async {
    return await repository.getAttribute(cookie: params.cookie);
  }
}

class GetAttributeParams extends Equatable {
  final String? cookie;

  const GetAttributeParams({this.cookie});

  @override
  List<Object?> get props => [cookie];
}
