import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/data/models/report_orders_category_model.dart';
import 'package:revo_pos/layers/data/models/report_orders_coupon_model.dart';
import 'package:revo_pos/layers/data/models/report_orders_model.dart';
import 'package:revo_pos/layers/data/models/report_stock_model.dart';
import 'package:revo_pos/layers/data/models/step_model.dart';
import 'package:revo_pos/layers/data/models/step_product_detail_model.dart';
import 'package:revo_pos/layers/data/models/step_product_model.dart';
import 'package:revo_pos/layers/domain/entities/report_orders.dart';
import 'package:revo_pos/layers/domain/entities/report_stock.dart';
import 'package:revo_pos/layers/domain/usecases/reports/get_report_orders_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/reports/get_report_stock_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/reports/update_report_stock_usecase.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ReportsNotifier with ChangeNotifier {
  final GetReportStockUsecase _getReportStockUsecase;
  final UpdateReportStockUsecase _updateReportStockUsecase;
  final GetReportOrdersUsecase _getReportOrdersUsecase;
  ReportsNotifier(
      {required GetReportStockUsecase getReportStockUsecase,
      required UpdateReportStockUsecase updateReportStockUsecase,
      required GetReportOrdersUsecase getReportOrdersUsecase})
      : _getReportStockUsecase = getReportStockUsecase,
        _updateReportStockUsecase = updateReportStockUsecase,
        _getReportOrdersUsecase = getReportOrdersUsecase;

  final now = DateTime.now();
  int selectedTab = 1;
  int selectedOrdersFilter = 0;
  int selectedOrdersDateFilter = 3;
  String status = "";
  bool loadingStock = false;
  bool loadingUpdate = false;
  bool loadingOrder = false;
  String filterOrder = "";
  String dateFilter = "";
  List<ReportStock> listReportStock = [];
  List<ReportStock> tempReportStock = [];
  ReportOrders? reportOrder;
  List<String> titleReportOrders = [];
  List<String> valueReportOrders = [];
  List<Color> listColor = [
    HexColor("#DC133D"),
    HexColor("#3000EB"),
    HexColor("#01C1FF"),
    HexColor("#02FED1"),
    HexColor("#00DF8F"),
    HexColor("#FED700"),
    HexColor("#FDA600")
  ];
  List<Color> listSecondColor = [HexColor("#5D5FEF"), HexColor("#EF5DA8")];
  List<String> titleSecondReportOrders = [];
  List<String> valueSecondReportOrders = [];
  PickerDateRange? dateRange = PickerDateRange(
      DateTime.now(), DateTime.now().add(const Duration(days: 3)));

  List<String> listFilter = [
    "Sales by date",
    "Sales by product",
    "Sales by category",
    "Coupon by date"
  ];
  List<String> listFilterVal = ["date", "product", "category", "coupon"];
  List<String> listDateFilter = [
    "Year",
    "Last month",
    "This month",
    "Last 7 day",
    "Custom range"
  ];
  int pages = 1;

  int maxValue = 0;
  List<FlSpot> spotSales = [];
  List<FlSpot> spotShipping = [];
  List<FlSpot> spotDiscount = [];
  List<FlSpot> spotNetSales = [];
  List<FlSpot> spotOrders = [];
  List<FlSpot> spotItems = [];
  List<LineChartBarData> lineChart = [];
  List<StepModel> listStep = [];
  List<StepModel> tempListStep = [];
  List<StepProductModel> listStepProduct = [];
  List<StepProductModel> tempListStepProduct = [];
  StepProductDetailModel? stepProductDetail;
  List<FlSpot> spotDetailEarn = [];
  List<FlSpot> spotDetailItems = [];
  List<BarChartGroupData> listBar = [];
  ReportOrdersCouponModel? coupon;
  List<FlSpot> spotCouponTotal = [];
  List<FlSpot> spotCouponUsed = [];
  int maxUsed = 0;

  Future<void> getProducts(
      {String? search, String? filter, int? productId}) async {
    loadingStock = true;
    notifyListeners();
    if (filter!.toLowerCase() == "all stock") {
      filter = "";
    }
    final result = await _getReportStockUsecase(GetReportStockParams(
        search: search, filter: filter, page: pages, productId: productId));

    result.fold((l) {
      listReportStock = [];
      loadingStock = false;
    }, (r) {
      tempReportStock = [];
      tempReportStock.addAll(r);
      List<ReportStock> list = List.from(listReportStock);
      list.addAll(tempReportStock);
      listReportStock = list;
      if (tempReportStock.length % 10 == 0) {
        pages++;
      }
      printLog("listReportStock : ${json.encode(listReportStock)}");
    });
    loadingStock = false;
    notifyListeners();
  }

  Future<bool> getReportOrders(context,
      {String? salesBy,
      String? period,
      String? step,
      int? productId,
      String? startDate,
      String? endDate}) async {
    loadingOrder = true;
    notifyListeners();
    final result = await _getReportOrdersUsecase(GetReportOrdersParams(
        salesBy: salesBy,
        period: period,
        step: step,
        productId: productId,
        startDate: startDate,
        endDate: endDate));

    result.fold((l) {
      reportOrder = null;
      loadingOrder = false;
    }, (r) {
      if (salesBy == "date") {
        reportOrder = r;
        titleReportOrders.clear();
        valueReportOrders.clear();
        titleSecondReportOrders.clear();
        valueSecondReportOrders.clear();
        lineChart.clear();
        spotSales.clear();
        spotShipping.clear();
        spotNetSales.clear();
        spotDiscount.clear();
        spotOrders.clear();
        spotItems.clear();
        for (int i = 0; i < reportOrder!.totals!.length; i++) {
          spotSales.add(FlSpot(
              i.toDouble(), reportOrder!.totals![i].salesFormated!.toDouble()));
          spotShipping.add(FlSpot(i.toDouble(),
              reportOrder!.totals![i].shippingFormated!.toDouble()));
          spotDiscount.add(FlSpot(i.toDouble(),
              reportOrder!.totals![i].discountFormated!.toDouble()));
          spotNetSales.add(FlSpot(i.toDouble(),
              reportOrder!.totals![i].netSalesFormated!.toDouble()));
          spotOrders.add(
              FlSpot(i.toDouble(), reportOrder!.totals![i].orders!.toDouble()));
          spotItems.add(
              FlSpot(i.toDouble(), reportOrder!.totals![i].items!.toDouble()));
        }
        printLog("line chart : $lineChart");
        //first part
        //title
        titleReportOrders.add("Gross Sales in This Period");
        titleReportOrders.add("Average Gross Daily Sales");
        titleReportOrders.add("Net Sales in This Period");
        titleReportOrders.add("Average Net Daily Sales");
        titleReportOrders.add("Charged for Shipping");
        titleReportOrders.add(
            "Refunded ${reportOrder!.totalRefundOrders} Orders (${reportOrder!.refundOrderItems} items)");
        titleReportOrders.add("Worth of Coupons Used");
        //value
        valueReportOrders.add(reportOrder!.totalSales!);
        valueReportOrders.add(reportOrder!.avgGross!);
        valueReportOrders.add(reportOrder!.netSales!);
        valueReportOrders.add(reportOrder!.avgSales!);
        valueReportOrders.add(reportOrder!.totalShipping!);
        valueReportOrders.add(reportOrder!.totalRefunds!.toString());
        valueReportOrders.add(reportOrder!.totalDiscount!);
        //second part
        //title
        titleSecondReportOrders.add("Orders Placed");
        titleSecondReportOrders.add("Item Purchased");
        //value
        valueSecondReportOrders.add(reportOrder!.totalOrders.toString());
        valueSecondReportOrders.add(reportOrder!.totalItems.toString());
        //END OF INSERT DATA
        printLog("report order : ${json.encode(reportOrder)}");
        return true;
      } else if (salesBy == "product") {
        if (step == "") {
          tempListStep = [];
          listStep.clear();
          tempListStep = r.cast<StepModel>();
          List<StepModel> list = List.from(listStep);
          list.addAll(tempListStep);
          listStep = list;
          printLog(json.encode(listStep), name: "STEP");
          return true;
        } else if (step != "" && step != null) {
          listStepProduct.clear();
          tempListStepProduct = [];
          tempListStepProduct = r.cast<StepProductModel>();
          List<StepProductModel> listP = List.from(listStepProduct);
          listP.addAll(tempListStepProduct);
          listStepProduct = listP;
          return true;
        } else if (productId != null) {
          stepProductDetail = r;
          spotDetailEarn.clear();
          spotDetailItems.clear();
          for (int i = 0; i < stepProductDetail!.totals!.length; i++) {
            spotDetailEarn.add(FlSpot(i.toDouble(),
                stepProductDetail!.totals![i].salesFormated!.toDouble()));
            spotDetailItems.add(FlSpot(
                i.toDouble(), stepProductDetail!.totals![i].items!.toDouble()));
          }
          return true;
        }
      } else if (salesBy == "category") {
        listCategory.clear();
        tempListCategory = [];
        tempListCategory = r.cast<ReportOrdersCategoryModel>();
        List<ReportOrdersCategoryModel> listP = List.from(listCategory);
        listP.addAll(tempListCategory);
        listCategory = listP;
        listBar.clear();
        for (int i = 0; i < listCategory.length; i++) {
          if (i > 0) {
            if (maxValue < listCategory[i].totalSalesFormated!) {
              maxValue = listCategory[i].totalSalesFormated!.toInt();
            }
          } else {
            maxValue = listCategory[i].totalSalesFormated!.toInt();
          }
          listBar.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: listCategory[i].totalSalesFormated!.toDouble(),
                  color: Colors.blue)
            ],
            showingTooltipIndicators: [0],
          ));
        }
        return true;
      } else if (salesBy == "coupon") {
        coupon = r;
        spotCouponTotal.clear();
        spotCouponUsed.clear();
        for (int i = 0; i < coupon!.totals!.length; i++) {
          if (coupon!.totals![i].totalUsed! > maxUsed) {
            maxUsed = coupon!.totals![i].totalUsed!.toInt();
          }
          spotCouponTotal.add(FlSpot(i.toDouble(),
              coupon!.totals![i].totalDiscountFormated!.toDouble()));
          spotCouponUsed.add(
              FlSpot(i.toDouble(), coupon!.totals![i].totalUsed!.toDouble()));
        }
        loadingOrder = false;
        notifyListeners();
        return true;
      }
    });
    loadingOrder = false;
    notifyListeners();
    return false;
  }

  List<ReportOrdersCategoryModel> listCategory = [];
  List<ReportOrdersCategoryModel> tempListCategory = [];

  Future<String> stocksUpdate(
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
    loadingUpdate = true;
    notifyListeners();

    printLog(productStatus.toString(), name: "Product Status notifier");
    final result = await _updateReportStockUsecase(UpdateReportStockParams(
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
    ));

    result.fold((l) {
      loadingUpdate = false;
    }, (r) {
      status = r['status'];
      return status;
    });
    loadingUpdate = false;
    notifyListeners();
    return status;
  }

  Future<bool> reset() async {
    listReportStock.clear();
    tempReportStock.clear();
    pages = 1;
    notifyListeners();
    return true;
  }

  setSelectedTab(int value) {
    selectedTab = value;
    notifyListeners();
  }

  setSelectedOrdersFilter(int value) {
    selectedOrdersFilter = value;
    filterOrder = listFilterVal[value];
    notifyListeners();
  }

  setSelectedOrdersDateFilter(int value) {
    selectedOrdersDateFilter = value;
    if (value == 0) {
      dateFilter = "year";
    } else if (value == 1) {
      dateFilter = "last_month";
    } else if (value == 2) {
      dateFilter = "month";
    } else if (value == 3) {
      dateFilter = "week";
    } else if (value == 4) {
      dateFilter = "custom";
    }
    notifyListeners();
  }

  setDateRange(PickerDateRange? value) {
    dateRange = value;
    notifyListeners();
  }
}
