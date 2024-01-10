import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/reports/widget/bottom_sheet_orders_product.dart';
import 'package:revo_pos/layers/presentation/reports/widget/item_order_category.dart';

class OrdersSalesByCategoryPage extends StatefulWidget {
  const OrdersSalesByCategoryPage({Key? key}) : super(key: key);

  @override
  _OrdersSalesByCategoryPageState createState() =>
      _OrdersSalesByCategoryPageState();
}

class _OrdersSalesByCategoryPageState extends State<OrdersSalesByCategoryPage> {
  ReportsNotifier? reportsNotifier;

  @override
  void initState() {
    super.initState();
    reportsNotifier = Provider.of<ReportsNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ReportsNotifier>().getReportOrders(context,
          salesBy: "category",
          period:
              Provider.of<ReportsNotifier>(context, listen: false).dateFilter,
          startDate: Provider.of<ReportsNotifier>(context, listen: false)
              .dateRange!
              .startDate
              .toString()
              .substring(0, 10),
          endDate: Provider.of<ReportsNotifier>(context, listen: false)
              .dateRange!
              .endDate
              .toString()
              .substring(0, 10));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsNotifier>(
      builder: (context, value, child) {
        return value.loadingOrder
            ? Center(
                child: CircularProgressIndicator(color: colorPrimary),
              )
            : Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: buildChart(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: reportsNotifier!.listCategory.length,
                      itemBuilder: (_, index) => ItemOrderCategory(
                        id: value.listCategory[index].categoryId.toString(),
                        name: value.listCategory[index].categoryName,
                        image: value.listCategory[index].image,
                        item:
                            value.listCategory[index].countProducts.toString(),
                        totalSales:
                            value.listCategory[index].totalSales.toString(),
                        //onTap: showBottomSheetProducts,
                      ),
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                    ),
                  ),
                ],
              );
      },
    );
  }

  Widget buildChart() {
    return BarChart(
      BarChartData(
          barTouchData: barTouchData,
          titlesData: titlesData,
          borderData: borderData,
          barGroups: reportsNotifier!.listBar,
          gridData: FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: reportsNotifier!.maxValue.toDouble()),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              "",
              const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text = "";
    for (int i = 0; i < reportsNotifier!.listCategory.length; i++) {
      if (value.toInt() == i) {
        printLog("name : ${reportsNotifier!.listCategory[i].categoryId!}");
        text = "#${reportsNotifier!.listCategory[i].categoryId.toString()}";
      }
    }

    return Text(text, style: style);
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
      );

  final _barsGradient = const LinearGradient(
    colors: [
      Colors.lightBlueAccent,
      Colors.greenAccent,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  showBottomSheetProducts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: RevoPosMediaQuery.getWidth(context) * 0.5,
              height: 8,
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Container(
                height: RevoPosMediaQuery.getHeight(context) - 60,
                padding: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: BottomSheetOrdersProduct())
          ],
        );
      },
    );
  }
}
