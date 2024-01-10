import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/data/models/step_product_model.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/reports/page/detail_sale_by_product_page.dart';
import 'package:provider/provider.dart';
import 'item_order_product.dart';

class BottomSheetOrdersProduct extends StatefulWidget {
  final List<StepProductModel>? step;
  final int? idx;
  const BottomSheetOrdersProduct({Key? key, this.step, this.idx})
      : super(key: key);

  @override
  _BottomSheetOrdersProductState createState() =>
      _BottomSheetOrdersProductState();
}

class _BottomSheetOrdersProductState extends State<BottomSheetOrdersProduct> {
  @override
  Widget build(BuildContext context) {
    return widget.step!.length == 0
        ? Center(
            child: Text(
              "No products found in range",
              style: Theme.of(context).textTheme.headline5!,
              textAlign: TextAlign.center,
            ),
          )
        : Consumer<ReportsNotifier>(
            builder: (context, value, child) {
              return value.loadingOrder
                  ? Center(
                      child: CircularProgressIndicator(color: colorPrimary),
                    )
                  : ListView.separated(
                      itemCount: widget.step!.length,
                      itemBuilder: (_, index) => ItemOrderProduct(
                        url: widget.step![index].image,
                        name: widget.step![index].productName,
                        total: widget.idx == 2
                            ? "${MultiCurrency.convert(double.parse(widget.step![index].total!), context)}"
                            : "${widget.step![index].total} products",
                        onTap: () {
                          context
                              .read<ReportsNotifier>()
                              .getReportOrders(context,
                                  salesBy: "product",
                                  period: Provider.of<ReportsNotifier>(context,
                                          listen: false)
                                      .dateFilter,
                                  startDate: Provider.of<ReportsNotifier>(
                                          context,
                                          listen: false)
                                      .dateRange!
                                      .startDate
                                      .toString()
                                      .substring(0, 10),
                                  endDate: Provider.of<ReportsNotifier>(context,
                                          listen: false)
                                      .dateRange!
                                      .endDate
                                      .toString()
                                      .substring(0, 10),
                                  productId:
                                      int.parse(widget.step![index].productId!))
                              .then((value) {
                            Navigator.push(
                                context,
                                RevoPosRouteBuilder.routeBuilder(
                                    DetailSaleByProductPage(
                                  productDetail: Provider.of<ReportsNotifier>(
                                          context,
                                          listen: false)
                                      .stepProductDetail!,
                                )));
                          });
                        },
                      ),
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                    );
            },
          );
  }
}
