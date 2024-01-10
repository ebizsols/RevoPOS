import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/domain/entities/report_stock.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/reports/page/reports_stocks_variant_page.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dropdown.dart';
import 'package:revo_pos/layers/presentation/reports/widget/bottom_sheet_detail_reports_stock.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';
import 'package:revo_pos/layers/presentation/revo_pos_text_field.dart';

class ReportsStocksPage extends StatefulWidget {
  const ReportsStocksPage({Key? key}) : super(key: key);

  @override
  _ReportsStocksPageState createState() => _ReportsStocksPageState();
}

class _ReportsStocksPageState extends State<ReportsStocksPage> {
  TextEditingController? search;
  final ScrollController _scrollController = ScrollController();
  bool clear = false;
  String filter = "All stock";
  int page = 1;
  ReportsNotifier? reportsNotifier;
  @override
  void initState() {
    super.initState();
    search = TextEditingController();
    reportsNotifier = Provider.of<ReportsNotifier>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          context.read<ReportsNotifier>().tempReportStock.length % 10 == 0) {
        if (!reportsNotifier!.loadingStock) {
          context
              .read<ReportsNotifier>()
              .getProducts(search: search!.text, filter: filter);
          page++;
        }
      }
    });

    printLog("Search : ${search!.text} - filter : $filter");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      page = 1;
      context.read<ReportsNotifier>().reset();
      context
          .read<ReportsNotifier>()
          .getProducts(search: search!.text, filter: filter);
    });
  }

  getProduct() {
    String fil = filter.toLowerCase();
    String sch = search!.text;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      page = 1;
      context.read<ReportsNotifier>().reset();
      context.read<ReportsNotifier>().getProducts(search: sch, filter: fil);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoadingProducts =
        context.select((ReportsNotifier n) => n.loadingStock);
    final pages = context.select((ReportsNotifier n) => n.pages);
    final tempList = context.select((ReportsNotifier n) => n.tempReportStock);
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevoPosTextField(
              controller: search!,
              maxLines: 1,
              onTap: () {
                setState(() {
                  clear = true;
                });
              },
              onComplete: () {
                setState(() {
                  clear = true;
                });
                getProduct();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              hintText: "Search",
              suffixIcon: clear || search!.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          search!.clear();
                          filter = "All stock";
                          clear = false;
                        });
                        getProduct();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: colorPrimary,
                      ),
                    )
                  : null,
              onChanged: (val) {}),
          const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(
              "Filter : ",
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(
              width: 150,
              child: RevoPosDropdown(
                value: filter,
                items: const [
                  "All stock",
                  "Available",
                  "Low stock",
                  "Out of stock"
                ],
                itemBuilder: (value) =>
                    DropdownMenuItem(value: value, child: Text(value)),
                onChanged: (value) {
                  setState(() {
                    filter = value;
                  });
                  getProduct();
                },
              ),
            ),
            // const Spacer(),
            // Text(
            //   "${reportsNotifier!.listReportStock.length} item show",
            //   style: Theme.of(context).textTheme.headline6,
            // ),
          ]),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 140,
                child: Text(
                  "Item Product",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              const Spacer(),
              Container(
                width: 80,
                child: Text(
                  "Status",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              const Spacer(),
              Container(
                width: 55,
                child: Text(
                  "Action",
                  style: Theme.of(context).textTheme.headline6,
                ),
              )
            ],
          ),
          Consumer<ReportsNotifier>(
            builder: (context, value, child) {
              if (isLoadingProducts && pages == 1) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colorPrimary,
                  ),
                );
              }
              printLog("Length : ${value.listReportStock.length}");
              return Expanded(
                flex: 12,
                child: ListView.separated(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: value.listReportStock.length,
                  itemBuilder: (_, index) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 140,
                        child: Text(
                          value.listReportStock[index].name!,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      const Spacer(),
                      // Container(
                      //   width: 80,
                      //   child: Text(
                      //     value.listReportStock[index].status!,
                      //     style: Theme.of(context)
                      //         .textTheme
                      //         .bodyText1!
                      //         .copyWith(
                      //             fontWeight: FontWeight.bold,
                      //             color: value.listReportStock[index].status! ==
                      //                     "available"
                      //                 ? Colors.green
                      //                 : value.listReportStock[index].status! ==
                      //                         "out of stock"
                      //                     ? colorDanger
                      //                     : Colors.orange),
                      //   ),
                      // ),
                      Container(
                        width: 80,
                        child: Text(
                          value.listReportStock[index].productStatus! ==
                                  "publish"
                              ? "Publish"
                              : value.listReportStock[index].productStatus! ==
                                      "draft"
                                  ? "Draft"
                                  : value.listReportStock[index]
                                              .productStatus! ==
                                          "pending"
                                      ? "Pending"
                                      : "",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: value.listReportStock[index]
                                              .productStatus! ==
                                          "publish"
                                      ? Colors.green
                                      : value.listReportStock[index]
                                                  .productStatus! ==
                                              "draft"
                                          ? colorDanger
                                          : value.listReportStock[index]
                                                      .productStatus! ==
                                                  "pending"
                                              ? Colors.yellow
                                              : Colors.black),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 50,
                        child: SizedBox(
                          width: 50,
                          child: RevoPosButton(
                              text: "Detail",
                              fontSize: 12,
                              radius: 10,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              onPressed: () {
                                if (value.listReportStock[index].type ==
                                    "simple") {
                                  showBottomSheetDetail(
                                    value.listReportStock[index],
                                    search!.text,
                                  );
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReportStockVariantPage(
                                          searchValue: search!.text,
                                          report: value.listReportStock[index],
                                        ),
                                      ));
                                }
                              }),
                        ),
                      ),
                    ],
                  ),
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                ),
              );
            },
          ),
          if (pages != 1 && tempList.length % 10 == 0 && isLoadingProducts)
            Center(
              child: CircularProgressIndicator(
                color: colorPrimary,
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  showBottomSheetDetail(ReportStock report, String searchValue) {
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
                height: MediaQuery.of(context).size.height - 100,
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: BottomSheetDetailReportsStock(
                  report: report,
                  searchValue: searchValue,
                  isProductVariant: false,
                ))
          ],
        );
      },
    );
  }
}
