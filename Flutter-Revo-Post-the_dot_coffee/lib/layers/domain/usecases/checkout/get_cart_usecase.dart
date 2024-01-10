import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/domain/repositories/cart_repository.dart';

class GetCartUsecase
    extends UseCase<List<ProductModel>, NoParams> {
  final CartRepository repository;

  GetCartUsecase(this.repository);

  @override
  Future<Either<Failure, List<ProductModel>>> call(NoParams params) async {
    return await repository.getCart();
  }
}
