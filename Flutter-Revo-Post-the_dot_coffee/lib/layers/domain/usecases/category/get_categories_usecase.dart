import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';
import 'package:revo_pos/layers/domain/repositories/category_repository.dart';

class GetCategoriesUsecase
    extends UseCase<List<Category>, GetCategoriesParams> {
  final CategoryRepository repository;

  GetCategoriesUsecase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(
      GetCategoriesParams params) async {
    return await repository.getCategories(
        page: params.page, limit: params.limit, search: params.search);
  }
}

class GetCategoriesParams extends Equatable {
  final int? page;
  final int? limit;
  final String? search;

  const GetCategoriesParams({this.page, this.limit, this.search});

  @override
  List<Object?> get props => [page, limit];
}
