import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/layers/data/models/report_orders_coupon_model.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../widget/item_report_order.dart';

class OrdersCouponByDatePage extends StatefulWidget {
  const OrdersCouponByDatePage({Key? key}) : super(key: key);

  @override
  _OrdersCouponByDatePageState createState() => _OrdersCouponByDatePageState();
}

class _OrdersCouponByDatePageState extends State<OrdersCouponByDatePage> {
  ReportsNotifier? reportsNotifier;
  @override
  void initState() {
    super.initState();
    reportsNotifier = Provider.of<ReportsNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ReportsNotifier>().getReportOrders(
            context,
            period: reportsNotifier!.dateFilter,
            startDate: reportsNotifier!.dateRange!.startDate
                .toString()
                .substring(0, 10),
            endDate:
                reportsNotifier!.dateRange!.endDate.toString().substring(0, 10),
            salesBy: "coupon",
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<ReportsNotifier>(
        builder: (context, value, child) {
          return value.loadingOrder
              ? Center(
                  child: CircularProgressIndicator(color: colorPrimary),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(18),
                            ),
                          ),
                          child: LineChart(chart(value.coupon!)),
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
                          itemCount: 1,
                          itemBuilder: (_, index) => ItemReportOrder(
                                firstPart: true,
                                value: value.coupon!.totalDiscount,
                                text: "Discount in total",
                                indicatorColor: Colors.blue,
                              )),
                      const SizedBox(height: 32),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(18),
                            ),
                          ),
                          child: LineChart(secondChart()),
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
                          itemCount: 1,
                          itemBuilder: (_, index) => ItemReportOrder(
                                firstPart: false,
                                value: value.coupon!.couponUsed.toString(),
                                text: "Coupon used in total",
                                indicatorColor: Colors.red,
                              )),
                    ],
                  ),
                );
        },
      ),
    );
  }

  LineChartData chart(ReportOrdersCouponModel coupon) {
    return LineChartData(
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
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: leftTitleWidgets),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 16,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          )),
      borderData: FlBorderData(show: true),
      minX: 0,
      minY: 0,
      maxY: coupon.maxY!.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: reportsNotifier!.spotCouponTotal,
          color: Colors.blue,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
          ),
        ),
      ],
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );
    String text = "";
    if (value.toInt() == (reportsNotifier!.coupon!.loopY! * 0)) {
      text = '0';
    } else if (value.toInt() == (reportsNotifier!.coupon!.loopY! * 1)) {
      text =
          '${reportsNotifier!.coupon!.loopY! * 1 * reportsNotifier!.coupon!.formatedValue!}';
    } else if (value.toInt() == (reportsNotifier!.coupon!.loopY! * 2)) {
      text =
          '${reportsNotifier!.coupon!.loopY! * 2 * reportsNotifier!.coupon!.formatedValue!}';
    } else if (value.toInt() == (reportsNotifier!.coupon!.loopY! * 3)) {
      text =
          '${reportsNotifier!.coupon!.loopY! * 3 * reportsNotifier!.coupon!.formatedValue!}';
    } else if (value.toInt() == (reportsNotifier!.coupon!.loopY! * 4)) {
      text =
          '${reportsNotifier!.coupon!.loopY! * 4 * reportsNotifier!.coupon!.formatedValue!}';
    } else if (value.toInt() == reportsNotifier!.coupon!.maxY!) {
      text =
          '${reportsNotifier!.coupon!.maxY! * reportsNotifier!.coupon!.formatedValue!}';
    }
    // switch ((value * 100).toInt()) {
    //   case 1:
    //     text = '10K';
    //     break;
    //   case 3:
    //     text = '30k';
    //     break;
    //   case 5:
    //     text = '50k';
    //     break;
    //   default:
    //     return Container();
    // }

    return Text(text, style: style, textAlign: TextAlign.left);
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
              DateTime.parse(reportsNotifier!.coupon!.totals![0].date!)),
          style: style,
        );
      }
      if (value.toInt() == 1) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![1].date!)),
          style: style,
        );
      }
      if (value.toInt() == 2) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![2].date!)),
          style: style,
        );
      }
      if (value.toInt() == 3) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![3].date!)),
          style: style,
        );
      }
      if (value.toInt() == 4) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![4].date!)),
          style: style,
        );
      }
      if (value.toInt() == 5) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![5].date!)),
          style: style,
        );
      }
      if (value.toInt() == 6) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![6].date!)),
          style: style,
        );
      }
    } else if (reportsNotifier!.dateFilter == "month" ||
        reportsNotifier!.dateFilter == "last_month") {
      if (value.toInt() % 5 == 0) {
        text = Text(
          DateFormat("dd MMM").format(DateTime.parse(
              reportsNotifier!.coupon!.totals![value.toInt()].date!)),
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
                  reportsNotifier!.coupon!.totals![value.toInt()].date!)),
              style: style,
            );
          }
        } else if ((temp / 24) > 7) {
          double mod = ((temp) / 24 / 6);
          if (value.toInt() % mod.round() == 0) {
            text = Text(
              DateFormat("dd MMM").format(DateTime.parse(
                  reportsNotifier!.coupon!.totals![value.toInt()].date!)),
              style: style,
            );
          }
        }
      }
    }

    return Padding(child: text, padding: const EdgeInsets.only(top: 8.0));
  }

  LineChartData secondChart() {
    return LineChartData(
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
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: secondLeftTitleWidgets),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 16,
              interval: 1,
              getTitlesWidget: secondBottomTitleWidgets,
            ),
          )),
      borderData: FlBorderData(show: true),
      minX: 0,
      minY: 0,
      maxY: (reportsNotifier!.coupon!.loopYitem! * 5),
      lineBarsData: [
        LineChartBarData(
          spots: reportsNotifier!.spotCouponUsed,
          color: Colors.red,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
          ),
        ),
      ],
    );
  }

  Widget secondLeftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );
    String text = "";
    if (value.toInt() == (reportsNotifier!.coupon!.loopYitem! * 0)) {
      text = '0';
    } else if (value.toInt() == (reportsNotifier!.coupon!.loopYitem! * 1)) {
      text = '${reportsNotifier!.coupon!.loopYitem! * 1}';
    } else if (value.toInt() == (reportsNotifier!.coupon!.loopYitem! * 2)) {
      text = '${reportsNotifier!.coupon!.loopYitem! * 2}';
    } else if (value.toInt() == reportsNotifier!.coupon!.loopYitem! * 3) {
      text = '${reportsNotifier!.coupon!.loopYitem! * 3}';
    } else if (value.toInt() == reportsNotifier!.coupon!.loopYitem! * 4) {
      text = '${reportsNotifier!.coupon!.loopYitem! * 4}';
    } else if (value.toInt() == (reportsNotifier!.coupon!.loopYitem! * 5)) {
      text = '${reportsNotifier!.coupon!.loopYitem! * 5}';
    }

    return Text(text, style: style, textAlign: TextAlign.left);
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
              DateTime.parse(reportsNotifier!.coupon!.totals![0].date!)),
          style: style,
        );
      }
      if (value.toInt() == 1) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![1].date!)),
          style: style,
        );
      }
      if (value.toInt() == 2) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![2].date!)),
          style: style,
        );
      }
      if (value.toInt() == 3) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![3].date!)),
          style: style,
        );
      }
      if (value.toInt() == 4) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![4].date!)),
          style: style,
        );
      }
      if (value.toInt() == 5) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![5].date!)),
          style: style,
        );
      }
      if (value.toInt() == 6) {
        text = Text(
          DateFormat("dd MMM").format(
              DateTime.parse(reportsNotifier!.coupon!.totals![6].date!)),
          style: style,
        );
      }
    } else if (reportsNotifier!.dateFilter == "month" ||
        reportsNotifier!.dateFilter == "last_month") {
      if (value.toInt() % 5 == 0) {
        text = Text(
          DateFormat("dd MMM").format(DateTime.parse(
              reportsNotifier!.coupon!.totals![value.toInt()].date!)),
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
                  reportsNotifier!.coupon!.totals![value.toInt()].date!)),
              style: style,
            );
          }
        } else if ((temp / 24) > 7) {
          double mod = ((temp) / 24 / 6);
          if (value.toInt() % mod.round() == 0) {
            text = Text(
              DateFormat("dd MMM").format(DateTime.parse(
                  reportsNotifier!.coupon!.totals![value.toInt()].date!)),
              style: style,
            );
          }
        }
      }
    }

    return Padding(child: text, padding: const EdgeInsets.only(top: 8.0));
  }
}
