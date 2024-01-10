import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/store_model.dart';
import 'package:revo_pos/layers/domain/repositories/store_repository.dart';

class GetStoresUsecase extends UseCase<List<StoreModel>, NoParams> {
  final StoreRepository repository;

  GetStoresUsecase(this.repository);

  @override
  Future<Either<Failure, List<StoreModel>>> call(NoParams params) async {
    return await repository.getStores();
  }
}