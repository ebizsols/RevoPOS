import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/domain/entities/report_orders.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/reports/widget/item_report_order.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class OrdersSalesByDatePage extends StatefulWidget {
  const OrdersSalesByDatePage({Key? key}) : super(key: key);

  @override
  _OrdersSalesByDatePageState createState() => _OrdersSalesByDatePageState();
}

class _OrdersSalesByDatePageState extends State<OrdersSalesByDatePage> {
  ReportsNotifier? reportsNotifier;
  int loopY = 0;
  @override
  void initState() {
    super.initState();
    reportsNotifier = Provider.of<ReportsNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ReportsNotifier>().getReportOrders(context,
          salesBy: "date",
          period: reportsNotifier!.dateFilter,
          startDate:
              reportsNotifier!.dateRange!.startDate.toString().substring(0, 10),
          endDate:
              reportsNotifier!.dateRange!.endDate.toString().substring(0, 10));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsNotifier>(
      builder: (context, value, child) {
        return value.loadingOrder
            ? Center(
                child: CircularProgressIndicator(
                color: colorPrimary,
              ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Consumer<ReportsNotifier>(
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 12),
                                  child: _buildChart(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              WaterfallFlow.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12),
                                  itemCount: 7,
                                  itemBuilder: (_, index) => ItemReportOrder(
                                        text: value.titleReportOrders[index],
                                        isGradient: index == 0,
                                        indicatorColor: index > 0
                                            ? value.listColor[index]
                                            : null,
                                        value: value.valueReportOrders[index],
                                        firstPart: true,
                                      )),
                              const SizedBox(height: 32),
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 12),
                                  child: _secondBuildChart(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              WaterfallFlow.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12),
                                  itemCount: 2,
                                  itemBuilder: (_, index) => ItemReportOrder(
                                        text: value
                                            .titleSecondReportOrders[index],
                                        indicatorColor:
                                            value.listSecondColor[index],
                                        value: value
                                            .valueSecondReportOrders[index],
                                        firstPart: false,
                                      )),
                            ],
                          );
                        },
                      ),
                    ),
                  )),
                  Card(
                    color: colorWhite,
                    margin: EdgeInsets.zero,
                    elevation: 12,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Total",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: colorBlack),
                            ),
                          ),
                          Text(
                            MultiCurrency.convert(
                                double.parse(value.reportOrder!.totalSales!),
                                context),
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
      },
    );
  }

  Widget _buildChart() {
    return LineChart(LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorDisabled,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: colorDisabled,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 45,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: 1,
                getTitlesWidget: bottomTitleWidgets),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          )),
      borderData: FlBorderData(show: true),
      minX: 0,
      minY: 0,
      lineBarsData: [
        LineChartBarData(
          spots: reportsNotifier!.spotSales,
          color: HexColor("#DC133D"),
          barWidth: 2,
          dotData: FlDotData(
            show: true,
          ),
        ),
        LineChartBarData(
          spots: reportsNotifier!.spotShipping,
          color: HexColor("#00DF8F"),
          barWidth: 2,
          dotData: FlDotData(
            show: true,
          ),
        ),
        LineChartBarData(
          spots: reportsNotifier!.spotDiscount,
          color: HexColor("#FDA600"),
          barWidth: 2,
          dotData: FlDotData(
            show: true,
          ),
        ),
        LineChartBarData(
          spots: reportsNotifier!.spotNetSales,
          color: HexColor("#01C1FF"),
          barWidth: 2,
          dotData: FlDotData(
            show: true,
          ),
        ),
      ],
    ));
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );
    String text = "";
    if (value.toInt() == (reportsNotifier!.reportOrder!.loopY! * 0)) {
      text = '0';
    } else if (value.toInt() == (reportsNotifier!.reportOrder!.loopY! * 1)) {
      text =
          '${reportsNotifier!.reportOrder!.loopY! * 1 * reportsNotifier!.reportOrder!.formatedValue!}';
    } else if (value.toInt() == (reportsNotifier!.reportOrder!.loopY! * 2)) {
      text =
          '${reportsNotifier!.reportOrder!.loopY! * 2 * reportsNotifier!.reportOrder!.formatedValue!}';
    } else if (value.toInt() == (reportsNotifier!.reportOrder!.loopY! * 3)) {
      text =
          '${reportsNotifier!.reportOrder!.loopY! * 3 * reportsNotifier!.reportOrder!.formatedValue!}';
    } else if (value.toInt() == (reportsNotifier!.reportOrder!.loopY! * 4)) {
      text =
          '${reportsNotifier!.reportOrder!.loopY! * 4 * reportsNotifier!.reportOrder!.formatedValue!}';
    } else if (value.toInt() == reportsNotifier!.reportOrder!.maxY! - 1) {
      text =
          '${reportsNotifier!.reportOrder!.maxY! * reportsNotifier!.reportOrder!.formatedValue!}';
    }
    // switch ((value).toInt()) {
    //   case 1:
    //     text = '10K';
    //     break;
    //   case 20:
    //     text = '30k';
    //     break;
    //   case 40:
    //     text = '50k';
    //     break;
    //   case 60:
    //     text = '50k';
    //     break;
    //   case 80:
    //     text = '50k';
    //     break;
    //   case 110:
    //     text = '20k';
    //     break;
    //   default:
    //     return Container();
    // }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );
    Widget text = Text("");

    if (reportsNotifier!.dateFilter == "week") {
      if (value.toInt() == 0) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![0].date!)),
          style: style,
        );
      }
      if (value.toInt() == 1) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![1].date!)),
          style: style,
        );
      }
      if (value.toInt() == 2) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![2].date!)),
          style: style,
        );
      }
      if (value.toInt() == 3) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![3].date!)),
          style: style,
        );
      }
      if (value.toInt() == 4) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![4].date!)),
          style: style,
        );
      }
      if (value.toInt() == 5) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![5].date!)),
          style: style,
        );
      }
      if (value.toInt() == 6) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![6].date!)),
          style: style,
        );
      }
    } else if (reportsNotifier!.dateFilter == "month" ||
        reportsNotifier!.dateFilter == "last_month") {
      if (value.toInt() % 5 == 0) {
        text = Text(
          DateFormat("dd MMM").format(DateTime.parse(
              reportsNotifier!.reportOrder!.totals![value.toInt()].date!)),
          style: style,
        );
      }
    } else if (reportsNotifier!.dateFilter == "year") {
      if (value.toInt() == 0) {
        text = const Text(
          "Jan",
          style: style,
        );
      }
      if (value.toInt() == 1) {
        text = const Text(
          "Feb",
          style: style,
        );
      }
      if (value.toInt() == 2) {
        text = const Text(
          "Mar",
          style: style,
        );
      }
      if (value.toInt() == 3) {
        text = const Text(
          "Apr",
          style: style,
        );
      }
      if (value.toInt() == 4) {
        text = const Text(
          "May",
          style: style,
        );
      }
      if (value.toInt() == 5) {
        text = const Text(
          "Jun",
          style: style,
        );
      }
      if (value.toInt() == 6) {
        text = const Text(
          "Jul",
          style: style,
        );
      }
      if (value.toInt() == 7) {
        text = const Text(
          "Aug",
          style: style,
        );
      }
      if (value.toInt() == 8) {
        text = const Text(
          "Sep",
          style: style,
        );
      }
      if (value.toInt() == 9) {
        text = const Text(
          "Okt",
          style: style,
        );
      }
      if (value.toInt() == 10) {
        text = const Text(
          "Nov",
          style: style,
        );
      }
      if (value.toInt() == 11) {
        text = const Text(
          "Dec",
          style: style,
        );
      }
    } else {
      if (reportsNotifier!.dateRange!.endDate != null &&
          reportsNotifier!.dateRange!.startDate != null) {
        String tempString = reportsNotifier!.dateRange!.endDate!
            .difference(reportsNotifier!.dateRange!.startDate!)
            .toString()
            .split(":")[0];
        int temp = int.parse(tempString) + 24;
        if ((temp / 24) <= 7) {
          if (value.toInt() % 1 == 0) {
            text = Text(
              DateFormat("dd MMM").format(DateTime.parse(
                  reportsNotifier!.reportOrder!.totals![value.toInt()].date!)),
              style: style,
            );
          }
        } else if ((temp / 24) > 7) {
          printLog(
              "Hour : ${reportsNotifier!.dateRange!.endDate!} ${(reportsNotifier!.dateRange!.startDate!).toString()}");
          printLog("temp : $temp");
          double mod = ((temp) / 24 / 6);
          printLog("mod : ${mod.round()}");
          if (value.toInt() % mod.round() == 0) {
            text = Text(
              DateFormat("dd MMM").format(DateTime.parse(
                  reportsNotifier!.reportOrder!.totals![value.toInt()].date!)),
              style: style,
            );
          }
        }
      }
    }
    return Padding(child: text, padding: const EdgeInsets.only(top: 8.0));
  }

  Widget _secondBuildChart() {
    return LineChart(LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorDisabled,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: colorDisabled,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: secondLeftTitleWidgets,
              reservedSize: 35,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: 1,
                getTitlesWidget: secondBottomTitleWidgets),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          )),
      borderData: FlBorderData(show: true),
      minX: 0,
      minY: 0,
      maxY: reportsNotifier!.reportOrder!.loopYItem! * 5,
      lineBarsData: [
        LineChartBarData(
          spots: reportsNotifier!.spotOrders,
          color: HexColor("#5D5FEF"),
          barWidth: 2,
          dotData: FlDotData(
            show: true,
          ),
        ),
        LineChartBarData(
          spots: reportsNotifier!.spotItems,
          color: HexColor("#EF5DA8"),
          barWidth: 2,
          dotData: FlDotData(
            show: true,
          ),
        ),
      ],
    ));
  }

  Widget secondLeftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );
    String text = "";
    if (value.toInt() == 0) {
      text = '0';
    } else if (value.toInt() ==
        (reportsNotifier!.reportOrder!.loopYItem! * 1)) {
      text = '${reportsNotifier!.reportOrder!.loopYItem! * 1}';
    } else if (value.toInt() ==
        (reportsNotifier!.reportOrder!.loopYItem! * 2)) {
      text = '${reportsNotifier!.reportOrder!.loopYItem! * 2}';
    } else if (value.toInt() ==
        (reportsNotifier!.reportOrder!.loopYItem! * 3)) {
      text = '${reportsNotifier!.reportOrder!.loopYItem! * 3}';
    } else if (value.toInt() ==
        (reportsNotifier!.reportOrder!.loopYItem! * 4)) {
      text = '${reportsNotifier!.reportOrder!.loopYItem! * 4}';
    } else if (value.toInt() ==
        ((reportsNotifier!.reportOrder!.loopYItem! * 5))) {
      text = '${reportsNotifier!.reportOrder!.loopYItem! * 5}';
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  Widget secondBottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );
    Widget text = Text("");

    if (reportsNotifier!.dateFilter == "week") {
      if (value.toInt() == 0) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![0].date!)),
          style: style,
        );
      }
      if (value.toInt() == 1) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![1].date!)),
          style: style,
        );
      }
      if (value.toInt() == 2) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![2].date!)),
          style: style,
        );
      }
      if (value.toInt() == 3) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![3].date!)),
          style: style,
        );
      }
      if (value.toInt() == 4) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![4].date!)),
          style: style,
        );
      }
      if (value.toInt() == 5) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![5].date!)),
          style: style,
        );
      }
      if (value.toInt() == 6) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.reportOrder!.totals![6].date!)),
          style: style,
        );
      }
    } else if (reportsNotifier!.dateFilter == "month" ||
        reportsNotifier!.dateFilter == "last_month") {
      if (value.toInt() % 5 == 0) {
        text = Text(
          DateFormat("dd MMM").format(DateTime.parse(
              reportsNotifier!.reportOrder!.totals![value.toInt()].date!)),
          style: style,
        );
      }
    } else if (reportsNotifier!.dateFilter == "year") {
      if (value.toInt() == 0) {
        text = const Text(
          "Jan",
          style: style,
        );
      }
      if (value.toInt() == 1) {
        text = const Text(
          "Feb",
          style: style,
        );
      }
      if (value.toInt() == 2) {
        text = const Text(
          "Mar",
          style: style,
        );
      }
      if (value.toInt() == 3) {
        text = const Text(
          "Apr",
          style: style,
        );
      }
      if (value.toInt() == 4) {
        text = const Text(
          "May",
          style: style,
        );
      }
      if (value.toInt() == 5) {
        text = const Text(
          "Jun",
          style: style,
        );
      }
      if (value.toInt() == 6) {
        text = const Text(
          "Jul",
          style: style,
        );
      }
      if (value.toInt() == 7) {
        text = const Text(
          "Aug",
          style: style,
        );
      }
      if (value.toInt() == 8) {
        text = const Text(
          "Sep",
          style: style,
        );
      }
      if (value.toInt() == 9) {
        text = const Text(
          "Okt",
          style: style,
        );
      }
      if (value.toInt() == 10) {
        text = const Text(
          "Nov",
          style: style,
        );
      }
      if (value.toInt() == 11) {
        text = const Text(
          "Dec",
          style: style,
        );
      }
    } else {
      if (reportsNotifier!.dateRange!.endDate != null &&
          reportsNotifier!.dateRange!.startDate != null) {
        String tempString = reportsNotifier!.dateRange!.endDate!
            .difference(reportsNotifier!.dateRange!.startDate!)
            .toString()
            .split(":")[0];
        int temp = int.parse(tempString) + 24;
        if ((temp / 24) <= 7) {
          if (value.toInt() % 1 == 0) {
            text = Text(
              DateFormat("dd MMM").format(DateTime.parse(
                  reportsNotifier!.reportOrder!.totals![value.toInt()].date!)),
              style: style,
            );
          }
        } else if ((temp / 24) > 7) {
          printLog(
              "Hour : ${reportsNotifier!.dateRange!.endDate!} ${(reportsNotifier!.dateRange!.startDate!).toString()}");
          printLog("temp : $temp");
          double mod = ((temp) / 24 / 6);
          printLog("mod : ${mod.round()}");
          if (value.toInt() % mod.round() == 0) {
            text = Text(
              DateFormat("dd MMM").format(DateTime.parse(
                  reportsNotifier!.reportOrder!.totals![value.toInt()].date!)),
              style: style,
            );
          }
        }
      }
    }
    return Padding(child: text, padding: const EdgeInsets.only(top: 8.0));
  }
}
