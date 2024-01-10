import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/report_stock_model.dart';
import 'package:revo_pos/layers/data/sources/remote/reports_remote_data_source.dart';
import 'package:revo_pos/layers/domain/entities/report_orders.dart';
import 'package:revo_pos/layers/domain/entities/report_stock.dart';
import 'package:revo_pos/layers/domain/repositories/report_repository.dart';

typedef _ListReportLoader = Future<List<ReportStock>> Function();
typedef _UpdateReportLoader = Future<Map<String, dynamic>> Function();
typedef _OrdersReportLoader = Future<dynamic> Function();

class ReportRepositoryImpl extends ReportRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ReportStock>>> getProducts(
      {String? search, String? filter, int? page, int? productId}) async {
    return await _getProducts(() {
      return remoteDataSource.getProducts(
          search: search, filter: filter, page: page, productId: productId);
    });
  }

  Future<Either<Failure, List<ReportStock>>> _getProducts(
      _ListReportLoader getProducts) async {
    try {
      final remote = await getProducts();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, dynamic>> getReportOrders(
      {String? salesBy,
      String? period,
      String? step,
      int? productId,
      String? startDate,
      String? endDate}) async {
    return await _getReportOrders(() {
      return remoteDataSource.getReportOrders(
          salesBy: salesBy,
          period: period,
          step: step,
          productId: productId,
          startDate: startDate,
          endDate: endDate);
    });
  }

  Future<Either<Failure, dynamic>> _getReportOrders(
      _OrdersReportLoader getReportOrders) async {
    try {
      final remote = await getReportOrders();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> stocksUpdate(
      {int? productId,
      String? type,
      bool? manageStock,
      String? stockStatus,
      int? stockQty,
      String? regPrice,
      String? salePrice,
      WholeSaleModel? wholeSale,
      String? productStatus,
      List<Map<String, dynamic>>? variations}) async {
    return await _stocksUpdate(() {
      return remoteDataSource.stocksUpdate(
        productId: productId,
        type: type,
        manageStock: manageStock,
        stockStatus: stockStatus,
        stockQty: stockQty,
        regPrice: regPrice,
        salePrice: salePrice,
        wholeSale: wholeSale,
        variations: variations,
        productStatus: productStatus,
      );
    });
  }

  Future<Either<Failure, Map<String, dynamic>>> _stocksUpdate(
      _UpdateReportLoader updateReport) async {
    try {
      final remote = await updateReport();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
