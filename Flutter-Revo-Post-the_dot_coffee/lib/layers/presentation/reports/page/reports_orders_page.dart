import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dropdown.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/reports/widget/bottom_sheet_date.dart';
import 'package:revo_pos/layers/presentation/reports/page/orders_coupon_by_date_page.dart';
import 'package:revo_pos/layers/presentation/reports/page/orders_sales_by_category_page.dart';
import 'package:revo_pos/layers/presentation/reports/page/orders_sales_by_date_page.dart';
import 'package:revo_pos/layers/presentation/reports/page/orders_sales_by_product_page.dart';
import 'package:provider/provider.dart';

class ReportsOrdersPage extends StatefulWidget {
  const ReportsOrdersPage({Key? key}) : super(key: key);

  @override
  _ReportsOrdersPageState createState() => _ReportsOrdersPageState();
}

class _ReportsOrdersPageState extends State<ReportsOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ReportsNotifier>().setSelectedOrdersDateFilter(3);
      context.read<ReportsNotifier>().setSelectedOrdersFilter(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter =
        context.select((ReportsNotifier n) => n.selectedOrdersFilter);
    final selectedDateFilter =
        context.select((ReportsNotifier n) => n.selectedOrdersDateFilter);

    final listFilter = context.select((ReportsNotifier n) => n.listFilter);
    final listDateFilter =
        context.select((ReportsNotifier n) => n.listDateFilter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: RevoPosDropdown(
                  value: selectedFilter,
                  items: listFilter,
                  itemBuilder: (value) => DropdownMenuItem(
                      value: listFilter.indexOf(value),
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyText1,
                      )),
                  onChanged: (value) {
                    context
                        .read<ReportsNotifier>()
                        .setSelectedOrdersFilter(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    showBottomSheetDate();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: colorDisabled,
                        ),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FaIcon(
                            FontAwesomeIcons.calendar,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            listDateFilter[selectedDateFilter],
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: LayoutBuilder(
          builder: (_, constraint) {
            switch (selectedFilter) {
              case 0:
                return const OrdersSalesByDatePage();
              case 1:
                return const OrdersSalesByProductPage();
              case 2:
                return const OrdersSalesByCategoryPage();
              default:
                return const OrdersCouponByDatePage();
            }
          },
        )),
      ],
    );
  }

  showBottomSheetDate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BottomSheetDate(),
    );
  }
}
