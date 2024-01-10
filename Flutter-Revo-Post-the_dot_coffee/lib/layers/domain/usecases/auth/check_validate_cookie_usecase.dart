import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/repositories/auth_repository.dart';

class CheckValidateCookieUsecase
    implements UseCase<Map<String, dynamic>, NoParams> {
  final AuthRepository repository;

  CheckValidateCookieUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.checkValidateCookie();
  }
}
