import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/data/models/report_stock_model.dart';
import 'package:revo_pos/layers/domain/entities/report_stock.dart';
import 'package:revo_pos/layers/domain/repositories/report_repository.dart';

class UpdateReportStockUsecase
    extends UseCase<Map<String, dynamic>, UpdateReportStockParams> {
  final ReportRepository repository;

  UpdateReportStockUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      UpdateReportStockParams params) async {
    return await repository.stocksUpdate(
      productId: params.productId,
      type: params.type,
      manageStock: params.manageStock,
      stockStatus: params.stockStatus,
      stockQty: params.stockQty,
      regPrice: params.regPrice,
      salePrice: params.salePrice,
      wholeSale: params.wholeSale,
      variations: params.variations,
      productStatus: params.productStatus,
    );
  }
}

class UpdateReportStockParams extends Equatable {
  final int? productId;
  final String? type;
  final bool? manageStock;
  final String? stockStatus;
  final int? stockQty;
  final String? regPrice;
  final String? salePrice;
  final WholeSaleModel? wholeSale;
  final List<Map<String, dynamic>>? variations;
  final String? productStatus;

  const UpdateReportStockParams(
      {this.productId,
      this.type,
      this.manageStock,
      this.stockStatus,
      this.stockQty,
      this.regPrice,
      this.salePrice,
      this.wholeSale,
      this.variations,
      this.productStatus});

  @override
  List<Object?> get props => [
        productId,
        type,
        manageStock,
        stockStatus,
        stockQty,
        regPrice,
        salePrice,
        wholeSale,
        variations,
        productStatus
      ];
}
