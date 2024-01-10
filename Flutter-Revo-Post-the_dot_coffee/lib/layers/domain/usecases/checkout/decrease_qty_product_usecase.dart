import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/domain/repositories/cart_repository.dart';

class DecreaseQtyProductUsecase extends UseCase<bool, DecreaseQtyParams> {
  final CartRepository repository;

  DecreaseQtyProductUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DecreaseQtyParams params) async {
    return await repository.decreaseQtyProduct(product: params.product);
  }
}

class DecreaseQtyParams extends Equatable {
  final ProductModel product;

  const DecreaseQtyParams({required this.product});

  @override
  List<Object> get props => [product];
}
