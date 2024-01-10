import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/customer_model.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/domain/repositories/cart_repository.dart';

class AddToCartUsecase
    extends UseCase<bool, AddToCartParams> {
  final CartRepository repository;

  AddToCartUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(
      AddToCartParams params) async {
    return await repository.addToCart(product: params.product);
  }
}

class AddToCartParams extends Equatable {
  final ProductModel product;

  const AddToCartParams({required this.product});

  @override
  List<Object> get props => [product];
}
