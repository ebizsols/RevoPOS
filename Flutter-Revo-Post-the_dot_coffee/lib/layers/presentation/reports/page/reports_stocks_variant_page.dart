import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/data/models/report_stock_model.dart';
import 'package:revo_pos/layers/domain/entities/report_stock.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/reports/widget/bottom_sheet_detail_reports_stock.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';

import '../../revo_pos_dropdown.dart';

class ReportStockVariantPage extends StatefulWidget {
  final ReportStock? report;
  final String? searchValue;
  const ReportStockVariantPage({Key? key, this.report, this.searchValue})
      : super(key: key);

  @override
  State<ReportStockVariantPage> createState() => _ReportStockVariantPageState();
}

class _ReportStockVariantPageState extends State<ReportStockVariantPage> {
  final ScrollController _scrollController = ScrollController();
  String newStatus = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ReportsNotifier>().reset();
      context
          .read<ReportsNotifier>()
          .getProducts(productId: widget.report!.id, filter: "", search: "");
    });
    newStatus = widget.report!.productStatus!;
    if (newStatus == "publish") {
      newStatus = "Publish";
    } else if (newStatus == "pending") {
      newStatus = "Pending";
    } else if (newStatus == "draft") {
      newStatus = "Draft";
    }
  }

  updateStock(dynamic value) {
    printLog(newStatus.toString(), name: "newstatus");
    printLog(widget.report!.stockStatus.toString(), name: "stock status");
    setState(() {
      newStatus = value;
    });
    var newStatus2 = "";

    if (newStatus == "Publish") {
      newStatus2 = "publish";
    } else if (newStatus == "Pending") {
      newStatus2 = "pending";
    } else if (newStatus == "Draft") {
      newStatus2 = "draft";
    }
    Provider.of<ReportsNotifier>(context, listen: false)
        .stocksUpdate(
          productId: widget.report!.id,
          type: widget.report!.type,
          productStatus: newStatus2,
        )
        .then(
          (value) => Provider.of<ReportsNotifier>(context, listen: false)
              .getProducts(
                  productId: widget.report!.id, filter: "", search: ""),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.searchValue != null && widget.searchValue != "") {
          printLog(widget.searchValue!, name: "SEARCH VALUE");
          printLog("searchValue tidak null");
          Provider.of<ReportsNotifier>(context, listen: false)
              .reset()
              .then((value) {
            if (value) {
              Provider.of<ReportsNotifier>(context, listen: false)
                  .getProducts(search: widget.searchValue, filter: "");
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Success update product")));
            }
          });
        } else {
          printLog("searchvalue null");
          await Provider.of<ReportsNotifier>(context, listen: false)
              .reset()
              .then((value) {
            Provider.of<ReportsNotifier>(context, listen: false)
                .getProducts(search: "", filter: "");
            Navigator.pop(context);
          });
        }

        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Container(
          child: Consumer<ReportsNotifier>(
            builder: (context, value, child) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFirstPart(),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                      endIndent: 2,
                      indent: 2,
                      height: 5,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    _buildSecondPart()
                  ]);
            },
          ),
        ),
      ),
    );
  }

  _buildSecondPart() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ListView(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          children: [
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
                  width: 50,
                  child: Text(
                    "Action",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                )
              ],
            ),
            Consumer<ReportsNotifier>(
              builder: (context, value, child) {
                printLog("Length : ${value.listReportStock.length}");
                return value.loadingStock
                    ? RevoPosLoading()
                    : Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount:
                              value.listReportStock[0].variations!.length,
                          itemBuilder: (_, index) {
                            String name = "";
                            var variations =
                                value.listReportStock[0].variations![index];
                            for (int i = 0;
                                i < variations.attributes!.length;
                                i++) {
                              if (i < (variations.attributes!.length - 1)) {
                                name += variations.attributes![i].value! + ", ";
                              } else {
                                name += variations.attributes![i].value!;
                              }
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 140,
                                  child: Text(
                                    name,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 80,
                                  child: Text(
                                    variations.status!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: variations.status! ==
                                                    "available"
                                                ? Colors.green
                                                : variations.status! ==
                                                        "out of stock"
                                                    ? colorDanger
                                                    : Colors.orange),
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        onPressed: () {
                                          showBottomSheetDetail(variations);
                                        }),
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 8),
                        ),
                      );
              },
            ),
          ],
        ),
      );

  showBottomSheetDetail(VariationsModel report) {
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
                  reportVariation: report,
                  report: widget.report,
                  isProductVariant: true,
                ))
          ],
        );
      },
    );
  }

  _buildFirstPart() => Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        child: Row(children: [
          SizedBox(
            width: 120,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: widget.report!.image!,
                placeholder: (context, url) => RevoPosLoading(),
                errorWidget: (context, url, error) =>
                    Icon(Icons.image_not_supported),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 200,
                child: Text(
                  widget.report!.name!,
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
              Text(
                "Stock   : ${widget.report!.stockQty == null ? widget.report!.stockStatus : "${widget.report!.stockQty} pcs"}",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    "Status",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    height: 45,
                    width: 145,
                    child: RevoPosDropdown(
                      borderColor: colorDisabled,
                      value: newStatus,
                      items: const [
                        "Publish",
                        "Pending",
                        "Draft",
                      ],
                      itemBuilder: (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                      onChanged: (value) {
                        updateStock(value);
                      },
                    ),
                  ),
                ],
              )

              // Text(
              //   "Status : ${widget.report!.status!}",
              //   style: Theme.of(context).textTheme.bodyText1,
              // )
            ],
          )
        ]),
      );

  _buildAppBar() => AppBar(
        backgroundColor: colorWhite,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Provider.of<ReportsNotifier>(context, listen: false)
                .reset()
                .then((value) {
              if (value) {
                Provider.of<ReportsNotifier>(context, listen: false)
                    .getProducts(search: "", filter: "");

                Navigator.pop(context);
              }
            });
          },
        ),
        title: Text(
          "VARIANT LIST",
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: colorBlack),
        ),
      );
}
