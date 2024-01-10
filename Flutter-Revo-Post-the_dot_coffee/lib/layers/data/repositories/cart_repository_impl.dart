import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/data/sources/local/cart_local_data_source.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/repositories/cart_repository.dart';

typedef _AddToCartLoader = Future<bool> Function();
typedef _GetCartLoader = Future<List<ProductModel>> Function();
typedef _IncreaseQtyProductLoader = Future<bool> Function();
typedef _DecreaseQtyProductLoader = Future<bool> Function();
typedef _RemoveCartProductLoader = Future<bool> Function();

class CartRepositoryImpl extends CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> addToCart(
      {required ProductModel product}) async {
    return await _addToCart(() {
      return localDataSource.addToCart(product: product);
    });
  }

  Future<Either<Failure, bool>> _addToCart(_AddToCartLoader addToCart) async {
    try {
      final remote = await addToCart();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getCart() async {
    return await _getCart(() {
      return localDataSource.getCart();
    });
  }

  Future<Either<Failure, List<ProductModel>>> _getCart(
      _GetCartLoader getCart) async {
    try {
      final remote = await getCart();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> decreaseQtyProduct({Product? product}) async {
    return await _decreaseQtyProduct(() {
      return localDataSource.decreaseQtyProduct(product: product);
    });
  }

  Future<Either<Failure, bool>> _decreaseQtyProduct(
      _DecreaseQtyProductLoader decreaseQtyProduct) async {
    try {
      final remote = await decreaseQtyProduct();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> increaseQtyProduct(
      {ProductModel? product}) async {
    return await _increaseQtyProduct(() {
      return localDataSource.increaseQtyProduct(product: product);
    });
  }

  Future<Either<Failure, bool>> _increaseQtyProduct(
      _IncreaseQtyProductLoader increaseQtyProduct) async {
    try {
      final remote = await increaseQtyProduct();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> removeCartProduct({Product? product}) async {
    return await _removeCartProduct(() {
      return localDataSource.removeCartProduct(product: product);
    });
  }

  Future<Either<Failure, bool>> _removeCartProduct(
      _RemoveCartProductLoader removeCartProduct) async {
    try {
      final remote = await removeCartProduct();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
