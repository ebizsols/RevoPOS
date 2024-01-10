import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/repositories/order_repository.dart';

class PrintInvUsecase
    extends UseCase<Map<String, dynamic>?, PrintInvParams> {
  final OrderRepository repository;

  PrintInvUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(
      PrintInvParams params) async {
    return await repository.printInv(
      cookie: params.cookie,
      idOrder: params.idOrder,
      storeName: params.storeName,
      storePhone: params.storePhone,
      storeAlamat: params.storeAlamat
    );
  }
}

class PrintInvParams extends Equatable {
  final String cookie;
  final int idOrder;
  final String storeName;
  final String storePhone;
  final String storeAlamat;

  const PrintInvParams({required this.cookie, required this.idOrder, required this.storeName, required this.storePhone, required this.storeAlamat});

  @override
  List<Object> get props => [
    cookie,
    idOrder,
    storeName,
    storePhone,
    storeAlamat
  ];
}
