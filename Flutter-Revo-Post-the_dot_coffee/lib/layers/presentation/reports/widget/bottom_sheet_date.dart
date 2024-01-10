import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/reports/widget/bottom_sheet_date_range.dart';

import 'item_filter_date.dart';

class BottomSheetDate extends StatefulWidget {
  const BottomSheetDate({Key? key}) : super(key: key);

  @override
  _BottomSheetDateState createState() => _BottomSheetDateState();
}

class _BottomSheetDateState extends State<BottomSheetDate> {
  ReportsNotifier? reportsNotifier;
  @override
  void initState() {
    super.initState();
    reportsNotifier = Provider.of<ReportsNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final selectedDate =
        context.select((ReportsNotifier n) => n.selectedOrdersDateFilter);
    final listDate = [
      {"title": "Year", "subtitle": "${now.year}", "period": "year"},
      {
        "title": "Last month",
        "subtitle": DateFormat("MMMM").format(now),
        "period": "last_month"
      },
      {
        "title": "This month",
        "subtitle": DateFormat("MMMM").format(now),
        "period": "month"
      },
      {
        "title": "Last 7 day",
        "subtitle": DateFormat("MMMM").format(now),
        "period": "week"
      },
      {"title": "Custom range", "period": "custom"},
    ];

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
                Text(
                  "Sort By Date",
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 20),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listDate.length,
                  itemBuilder: (_, index) => ItemFilterDate(
                      title: listDate[index]["title"]!,
                      subtitle: listDate[index]["subtitle"],
                      icon: FontAwesomeIcons.calendarAlt,
                      isSelected: index == selectedDate,
                      onTap: () async {
                        if (index == listDate.length - 1) {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const BottomSheetDateRange(),
                          );
                        } else {
                          context
                              .read<ReportsNotifier>()
                              .setSelectedOrdersDateFilter(index);
                          context.read<ReportsNotifier>().getReportOrders(
                              context,
                              period: listDate[index]['period'],
                              salesBy: reportsNotifier!.filterOrder);
                        }

                        Navigator.pop(context);
                      }),
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                )
              ],
            ))
      ],
    );
  }
}
