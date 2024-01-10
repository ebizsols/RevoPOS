import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class BottomSheetDateRange extends StatefulWidget {
  const BottomSheetDateRange({Key? key}) : super(key: key);

  @override
  _BottomSheetDateRangeState createState() => _BottomSheetDateRangeState();
}

class _BottomSheetDateRangeState extends State<BottomSheetDateRange> {
  PickerDateRange? range;
  ReportsNotifier? reportsNotifier;
  @override
  void initState() {
    super.initState();
    reportsNotifier = Provider.of<ReportsNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateRange =
        context.select((ReportsNotifier n) => n.dateRange);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: RevoPosMediaQuery.getWidth(context) * 0.5,
          height: 8,
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        Container(
            width: RevoPosMediaQuery.getWidth(context),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                SfDateRangePicker(
                  onSelectionChanged: (args) {
                    if (args.value is PickerDateRange) {
                      range = args.value;
                    }
                  },
                  selectionMode: DateRangePickerSelectionMode.range,
                  todayHighlightColor: Theme.of(context).primaryColor,
                  rangeSelectionColor: Theme.of(context).colorScheme.secondary,
                  startRangeSelectionColor: Theme.of(context).primaryColor,
                  endRangeSelectionColor: Theme.of(context).primaryColor,
                  headerStyle: DateRangePickerHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: Theme.of(context).textTheme.headline6),
                  monthCellStyle: DateRangePickerMonthCellStyle(
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.bold)),
                  rangeTextStyle: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                  selectionTextStyle: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: colorWhite, fontWeight: FontWeight.bold),
                  initialSelectedRange: selectedDateRange,
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 1,
                  child: RevoPosButton(
                      text: "Submit",
                      onPressed: () {
                        if (range != null) {
                          if (range!.startDate != null &&
                              range!.endDate != null) {
                            context
                                .read<ReportsNotifier>()
                                .setSelectedOrdersDateFilter(4);
                            context.read<ReportsNotifier>().setDateRange(range);
                            printLog(
                                "start : ${range!.startDate.toString().substring(0, 10)}");
                            context.read<ReportsNotifier>().getReportOrders(
                                context,
                                period: "custom",
                                salesBy: reportsNotifier!.filterOrder,
                                startDate: range!.startDate
                                    .toString()
                                    .substring(0, 10),
                                endDate:
                                    range!.endDate.toString().substring(0, 10));
                          } else {
                            context.read<ReportsNotifier>().setDateRange(null);
                          }
                        }

                        Navigator.pop(context);
                      }),
                )
              ],
            ))
      ],
    );
  }
}
