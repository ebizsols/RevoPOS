import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/sources/local/category_local_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/category_remote_data_source.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';
import 'package:revo_pos/layers/domain/repositories/category_repository.dart';

typedef _ListCategoryLoader = Future<List<Category>> Function();

class CategoryRepositoryImpl extends CategoryRepository {
  final CategoryLocalDataSource localDataSource;
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Category>>> getCategories(
      {int? page, int? limit, String? search}) async {
    return await _getCategories(() {
      return remoteDataSource.getCategories(
          page: page, limit: limit, search: search);
    });
  }

  Future<Either<Failure, List<Category>>> _getCategories(
      _ListCategoryLoader getCategories) async {
    try {
      final remote = await getCategories();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
