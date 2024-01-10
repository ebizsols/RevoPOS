import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/data/models/step_product_model.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/reports/widget/bottom_sheet_orders_product.dart';

class OrdersSalesByProductPage extends StatefulWidget {
  const OrdersSalesByProductPage({Key? key}) : super(key: key);

  @override
  _OrdersSalesByProductPageState createState() =>
      _OrdersSalesByProductPageState();
}

class _OrdersSalesByProductPageState extends State<OrdersSalesByProductPage> {
  ReportsNotifier? reportsNotifier;
  @override
  void initState() {
    super.initState();
    reportsNotifier = Provider.of<ReportsNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ReportsNotifier>().getReportOrders(context,
          salesBy: "product",
          period: reportsNotifier!.dateFilter,
          startDate:
              reportsNotifier!.dateRange!.startDate.toString().substring(0, 10),
          endDate:
              reportsNotifier!.dateRange!.endDate.toString().substring(0, 10),
          step: "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsNotifier>(
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: value.loadingOrder
              ? Center(
                  child: CircularProgressIndicator(
                    color: colorPrimary,
                  ),
                )
              : ListView.separated(
                  itemCount: value.listStep.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            value.listStep[index].title!,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    color: colorBlack,
                                    fontWeight: FontWeight.normal),
                          ),
                        ),
                        RevoPosButton(
                            text: "Detail",
                            onPressed: () {
                              printLog(value.listStep[index].slug!,
                                  name: "TEST");
                              context
                                  .read<ReportsNotifier>()
                                  .getReportOrders(context,
                                      salesBy: "product",
                                      period: value.dateFilter,
                                      startDate: reportsNotifier!
                                          .dateRange!.startDate
                                          .toString()
                                          .substring(0, 10),
                                      endDate: reportsNotifier!
                                          .dateRange!.endDate
                                          .toString()
                                          .substring(0, 10),
                                      step: value.listStep[index].slug)
                                  .then((val) {
                                //if (val) {
                                print(index);
                                showBottomSheetProducts(
                                    value.listStepProduct, index);
                                //}
                              });
                            })
                      ],
                    );
                  },
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                ),
        );
      },
    );
  }

  showBottomSheetProducts(List<StepProductModel> step, int index) {
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
                child: BottomSheetOrdersProduct(
                  step: step,
                  idx: index,
                ))
          ],
        );
      },
    );
  }
}
