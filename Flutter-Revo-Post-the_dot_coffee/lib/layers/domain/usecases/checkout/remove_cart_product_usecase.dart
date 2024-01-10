import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/domain/repositories/cart_repository.dart';

class RemoveCartProductUsecase extends UseCase<bool, RemoveCartProductParams> {
  final CartRepository repository;

  RemoveCartProductUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(RemoveCartProductParams params) async {
    return await repository.removeCartProduct(product: params.product);
  }
}

class RemoveCartProductParams extends Equatable {
  final ProductModel product;

  const RemoveCartProductParams({required this.product});

  @override
  List<Object> get props => [product];
}
