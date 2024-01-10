import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/variation_model.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';
import 'package:revo_pos/layers/domain/repositories/product_repository.dart';

class CheckVariationUsecase
    extends UseCase<Map<String, dynamic>, CheckVariationParams> {
  final ProductRepository repository;

  CheckVariationUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      CheckVariationParams params) async {
    return await repository.checkVariation(
        id: params.id, variation: params.variation);
  }
}

class CheckVariationParams extends Equatable {
  final String id;
  final List<VariationModel> variation;

  const CheckVariationParams({required this.id, required this.variation});

  @override
  List<Object?> get props => [id, variation];
}
