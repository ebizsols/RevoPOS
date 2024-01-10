import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/entities/report_stock.dart';
import 'package:revo_pos/layers/domain/repositories/product_repository.dart';
import 'package:revo_pos/layers/domain/repositories/report_repository.dart';

class GetReportStockUsecase
    extends UseCase<List<ReportStock>, GetReportStockParams> {
  final ReportRepository repository;

  GetReportStockUsecase(this.repository);

  @override
  Future<Either<Failure, List<ReportStock>>> call(
      GetReportStockParams params) async {
    return await repository.getProducts(
        search: params.search,
        filter: params.filter,
        page: params.page,
        productId: params.productId);
  }
}

class GetReportStockParams extends Equatable {
  final String? search;
  final String? filter;
  final int? page;
  final int? productId;

  const GetReportStockParams(
      {this.search, this.filter, this.page, this.productId});

  @override
  List<Object?> get props => [search, filter, page, productId];
}
