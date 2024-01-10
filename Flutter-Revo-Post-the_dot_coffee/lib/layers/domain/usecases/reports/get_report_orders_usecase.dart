import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/report_orders.dart';
import 'package:revo_pos/layers/domain/repositories/report_repository.dart';

class GetReportOrdersUsecase extends UseCase<dynamic, GetReportOrdersParams> {
  final ReportRepository repository;

  GetReportOrdersUsecase(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(GetReportOrdersParams params) async {
    return await repository.getReportOrders(
        salesBy: params.salesBy,
        period: params.period,
        step: params.step,
        productId: params.productId,
        startDate: params.startDate,
        endDate: params.endDate);
  }
}

class GetReportOrdersParams extends Equatable {
  final String? salesBy;
  final String? period;
  final String? step;
  final int? productId;
  final String? startDate;
  final String? endDate;

  const GetReportOrdersParams(
      {this.salesBy,
      this.period,
      this.step,
      this.productId,
      this.startDate,
      this.endDate});

  @override
  List<Object?> get props =>
      [salesBy, period, step, productId, startDate, endDate];
}
