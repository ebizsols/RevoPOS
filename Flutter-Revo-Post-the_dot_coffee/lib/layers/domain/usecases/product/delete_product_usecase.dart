import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';
import 'package:revo_pos/layers/domain/repositories/product_repository.dart';

class DeleteProductUsecase extends UseCase<Status, DeleteProductParams> {
  final ProductRepository repository;

  DeleteProductUsecase(this.repository);

  @override
  Future<Either<Failure, Status>> call(DeleteProductParams params) async {
    return await repository.deleteProduct(
      id: params.id,
      cookie: params.cookie
    );
  }
}

class DeleteProductParams extends Equatable {
  final String id;
  final String cookie;

  const DeleteProductParams({required this.id, required this.cookie});

  @override
  List<Object?> get props => [
    id,
    cookie
  ];
}