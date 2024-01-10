import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';

abstract class CartRepository {
  Future<Either<Failure, bool>> addToCart({required ProductModel product});
  Future<Either<Failure, List<ProductModel>>> getCart();
  Future<Either<Failure, bool>> increaseQtyProduct({ProductModel? product});
  Future<Either<Failure, bool>> decreaseQtyProduct({ProductModel? product});
  Future<Either<Failure, bool>> removeCartProduct({ProductModel? product});
}
