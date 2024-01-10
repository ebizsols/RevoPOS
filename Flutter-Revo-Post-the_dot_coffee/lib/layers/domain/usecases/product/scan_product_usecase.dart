import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/repositories/product_repository.dart';

class ScanProductUsecase extends UseCase<List<Product>, ScanProductParams> {
  final ProductRepository repository;

  ScanProductUsecase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(ScanProductParams params) async {
    return await repository.scanBarcode(
        sku: params.sku
    );
  }
}

class ScanProductParams extends Equatable {
  final String? sku;

  const ScanProductParams({
    this.sku
  });

  @override
  List<Object?> get props => [
    sku
  ];
}