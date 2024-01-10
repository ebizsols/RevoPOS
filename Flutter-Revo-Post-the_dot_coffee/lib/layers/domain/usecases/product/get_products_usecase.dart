import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/repositories/product_repository.dart';

class GetProductsUsecase extends UseCase<List<Product>, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUsecase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) async {
    return await repository.getProducts(
      search: params.search,
      categoryId: params.categoryId,
      page: params.page
    );
  }
}

class GetProductsParams extends Equatable {
  final String? search;
  final int? categoryId;
  final int? page;

  const GetProductsParams({
    this.search,
    this.categoryId,
    this.page
  });

  @override
  List<Object?> get props => [
    search,
    categoryId,
    page
  ];
}