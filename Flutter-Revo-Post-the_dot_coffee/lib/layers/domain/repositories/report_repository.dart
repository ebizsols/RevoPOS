import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/report_stock_model.dart';
import 'package:revo_pos/layers/domain/entities/report_orders.dart';
import 'package:revo_pos/layers/domain/entities/report_stock.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<ReportStock>>> getProducts(
      {String? search, String? filter, int? page, int? productId});

  Future<Either<Failure, Map<String, dynamic>>> stocksUpdate(
      {int? productId,
      String? type,
      bool? manageStock,
      String? stockStatus,
      int? stockQty,
      String? regPrice,
      String? salePrice,
      WholeSaleModel? wholeSale,
      List<Map<String, dynamic>>? variations,
      String? productStatus});

  Future<Either<Failure, dynamic>> getReportOrders(
      {String? salesBy,
      String? period,
      String? step,
      int? productId,
      String? startDate,
      String? endDate});
}
