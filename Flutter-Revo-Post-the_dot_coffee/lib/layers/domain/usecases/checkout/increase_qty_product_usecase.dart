import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/domain/repositories/cart_repository.dart';

class IncreaseQtyProductUsecase extends UseCase<bool, IncreaseQtyParams> {
  final CartRepository repository;

  IncreaseQtyProductUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(IncreaseQtyParams params) async {
    return await repository.increaseQtyProduct(product: params.product);
  }
}

class IncreaseQtyParams extends Equatable {
  final ProductModel product;

  const IncreaseQtyParams({required this.product});

  @override
  List<Object> get props => [product];
}
