import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories(
      {int? page, int? limit, String? search});
}
