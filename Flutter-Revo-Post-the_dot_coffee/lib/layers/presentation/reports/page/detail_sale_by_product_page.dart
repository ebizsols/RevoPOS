import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/data/models/step_product_detail_model.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';

class DetailSaleByProductPage extends StatefulWidget {
  final StepProductDetailModel? productDetail;
  DetailSaleByProductPage({Key? key, this.productDetail}) : super(key: key);

  @override
  _DetailSaleByProductPageState createState() =>
      _DetailSaleByProductPageState();
}

class _DetailSaleByProductPageState extends State<DetailSaleByProductPage> {
  ReportsNotifier? reportsNotifier;

  @override
  void initState() {
    super.initState();
    reportsNotifier = Provider.of<ReportsNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.productDetail!.image!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const RevoPosLoading(),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image_not_supported_rounded,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.productDetail!.productName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: colorBlack),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildInfo(),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: _buildChart(),
                ),
              ),
              const SizedBox(height: 20),
              _buildList(),
            ],
          ),
        ),
      ),
    );
  }

  _buildAppBar() => AppBar();

  Widget _buildInfo() => Row(
        children: [
          Expanded(
              child: Column(
            children: [
              Text(
                "Product sale",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                "${widget.productDetail!.totalItems}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: colorBlack),
              ),
            ],
          )),
          Expanded(
              child: Column(
            children: [
              Text(
                "Total",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                "${MultiCurrency.convert(double.parse(widget.productDetail!.totalSales!), context)}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: colorBlack),
              ),
            ],
          )),
        ],
      );

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
              reservedSize: 28,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
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
      maxY: widget.productDetail!.maxY!.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: reportsNotifier!.spotDetailEarn,
          color: Colors.red,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
          ),
        ),
        // LineChartBarData(
        //   spots: reportsNotifier!.spotDetailItems,
        //   color: Colors.blue,
        //   barWidth: 2,
        //   dotData: FlDotData(
        //     show: true,
        //   ),
        // ),
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
    if (value.toInt() == (widget.productDetail!.loopY! * 0)) {
      text = '0';
    } else if (value.toInt() == (widget.productDetail!.loopY! * 1)) {
      text =
          '${widget.productDetail!.loopY! * 1 * widget.productDetail!.formatedValue!}';
    } else if (value.toInt() == (widget.productDetail!.loopY! * 2)) {
      text =
          '${widget.productDetail!.loopY! * 2 * widget.productDetail!.formatedValue!}';
    } else if (value.toInt() == (widget.productDetail!.loopY! * 3)) {
      text =
          '${widget.productDetail!.loopY! * 3 * widget.productDetail!.formatedValue!}';
    } else if (value.toInt() == (widget.productDetail!.loopY! * 4)) {
      text =
          '${widget.productDetail!.loopY! * 4 * widget.productDetail!.formatedValue!}';
    } else if (value.toInt() == widget.productDetail!.maxY!) {
      text =
          '${widget.productDetail!.maxY! * widget.productDetail!.formatedValue!}';
    }

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
          DateFormat("dd MMM")
              .format(DateTime.parse(widget.productDetail!.totals![0].date!)),
          style: style,
        );
      }
      if (value.toInt() == 1) {
        text = Text(
          DateFormat("dd MMM")
              .format(DateTime.parse(widget.productDetail!.totals![1].date!)),
          style: style,
        );
      }
      if (value.toInt() == 2) {
        text = Text(
          DateFormat("dd MMM")
              .format(DateTime.parse(widget.productDetail!.totals![2].date!)),
          style: style,
        );
      }
      if (value.toInt() == 3) {
        text = Text(
          DateFormat("dd MMM")
              .format(DateTime.parse(widget.productDetail!.totals![3].date!)),
          style: style,
        );
      }
      if (value.toInt() == 4) {
        text = Text(
          DateFormat("dd MMM")
              .format(DateTime.parse(widget.productDetail!.totals![4].date!)),
          style: style,
        );
      }
      if (value.toInt() == 5) {
        text = Text(
          DateFormat("dd MMM")
              .format(DateTime.parse(widget.productDetail!.totals![5].date!)),
          style: style,
        );
      }
      if (value.toInt() == 6) {
        text = Text(
          DateFormat("dd MMM")
              .format(DateTime.parse(widget.productDetail!.totals![6].date!)),
          style: style,
        );
      }
    } else if (reportsNotifier!.dateFilter == "month" ||
        reportsNotifier!.dateFilter == "last_month") {
      if (value.toInt() % 5 == 0) {
        text = Text(
          DateFormat("dd MMM").format(DateTime.parse(
              widget.productDetail!.totals![value.toInt()].date!)),
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
                  widget.productDetail!.totals![value.toInt()].date!)),
              style: style,
            );
          }
        } else if ((temp / 24) > 7) {
          double mod = ((temp) / 24 / 6);
          if (value.toInt() % mod.round() == 0) {
            text = Text(
              DateFormat("dd MMM").format(DateTime.parse(
                  widget.productDetail!.totals![value.toInt()].date!)),
              style: style,
            );
          }
        }
      }
    }
    return Padding(child: text, padding: const EdgeInsets.only(top: 8.0));
  }

  Widget _buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(
              "Date",
              style: Theme.of(context).textTheme.headline6,
            )),
            Expanded(
                child: Text(
              "Products",
              style: Theme.of(context).textTheme.headline6,
            )),
            Expanded(
                child: Text(
              "Earnings",
              style: Theme.of(context).textTheme.headline6,
            ))
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.productDetail!.totals!.length,
          itemBuilder: (_, index) {
            String date = widget.productDetail!.totals![index].date!;

            String tempDate = "";
            if (reportsNotifier!.dateFilter != "year") {
              tempDate = DateFormat("dd-MM-yyyy").format(DateTime.parse(date));
            } else {
              tempDate = date;
            }
            return Row(
              children: [
                Expanded(
                    child: Text(
                  tempDate,
                  style: Theme.of(context).textTheme.bodyText1,
                )),
                Expanded(
                    child: Text(
                  "${widget.productDetail!.totals![index].items} products",
                  style: Theme.of(context).textTheme.bodyText1,
                )),
                Expanded(
                    child: Text(
                  "${MultiCurrency.convert(widget.productDetail!.totals![index].sales!.toDouble(), context)}",
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: colorBlack),
                ))
              ],
            );
          },
          separatorBuilder: (_, index) => const SizedBox(height: 12),
        )
      ],
    );
  }
}
