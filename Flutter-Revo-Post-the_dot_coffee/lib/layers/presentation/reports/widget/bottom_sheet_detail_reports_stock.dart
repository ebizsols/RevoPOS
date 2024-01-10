import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/report_stock_model.dart';
import 'package:revo_pos/layers/domain/entities/report_stock.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/detail_order_notifier.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dropdown.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';
import 'package:revo_pos/layers/presentation/revo_pos_text_field.dart';

import '../../revo_pos_icon_button.dart';

class BottomSheetDetailReportsStock extends StatefulWidget {
  final ReportStock? report;
  final VariationsModel? reportVariation;
  final String? searchValue;
  final bool? isProductVariant;
  const BottomSheetDetailReportsStock({
    Key? key,
    this.report,
    this.reportVariation,
    this.searchValue,
    this.isProductVariant,
  }) : super(key: key);

  @override
  _BottomSheetDetailReportsStockState createState() =>
      _BottomSheetDetailReportsStockState();
}

class _BottomSheetDetailReportsStockState
    extends State<BottomSheetDetailReportsStock> {
  final ScrollController _scrollController = ScrollController();
  int quantity = 1;
  int regPrice = 1300, salePrice = 1100, wholePrice = 1000;
  bool manageStock = false;
  String stockStatus = "In stock";
  String formatedStockStatus = "instock";
  String name = "";
  String status = "";
  String newStatus = "";
  String stock = "";
  bool loadingSave = false;
  TextEditingController? quantityController;
  TextEditingController? regPriceController,
      salePriceController,
      wholePriceController;

  @override
  void initState() {
    super.initState();
    getDataSimple();
    getDataVariation();
  }

  getDataVariation() {
    if (widget.reportVariation != null) {
      if (widget.reportVariation!.stockQty != null) {
        manageStock = true;
        quantity = widget.reportVariation!.stockQty!;
      } else if (widget.reportVariation!.stockQty == null) {
        if (widget.reportVariation!.status == "out of stock") {
          quantity = 0;
        } else {
          quantity = 999;
        }
      }
      for (int i = 0; i < widget.reportVariation!.attributes!.length; i++) {
        if (i < (widget.reportVariation!.attributes!.length - 1)) {
          name += widget.reportVariation!.attributes![i].value! + ", ";
        } else {
          name += widget.reportVariation!.attributes![i].value!;
        }
      }
      status = widget.reportVariation!.status!;
      newStatus = widget.report!.productStatus!;
      stock = widget.reportVariation!.stockQty == null
          ? widget.reportVariation!.stockStatus!
          : "${widget.reportVariation!.stockQty} pcs";

      if (newStatus == "publish") {
        newStatus = "Publish";
      } else if (newStatus == "pending") {
        newStatus = "Pending";
      } else if (newStatus == "draft") {
        newStatus = "Draft";
      }

      if (stock == "instock") {
        stock = "In Stock";
      } else if (stock == "outofstock") {
        stock = "Out of Stock";
      }
      quantityController = TextEditingController(text: "0");
      stockStatus = widget.reportVariation!.stockStatus!;
      formatedStockStatus = widget.reportVariation!.stockStatus!;
      if (stockStatus == "instock") {
        stockStatus = "In stock";
      } else if (stockStatus == "outofstock") {
        stockStatus = "Out of stock";
      }
      if (manageStock) {
        quantityController = TextEditingController(
            text: widget.reportVariation!.stockQty!.toString());
      }
      regPriceController = TextEditingController(
          text: widget.reportVariation!.regPrice.toString());
      salePriceController = TextEditingController(
          text: widget.reportVariation!.salePrice.toString());
      wholePriceController = TextEditingController(
          text: widget.reportVariation!.wholePrice.toString());
    }
  }

  getDataSimple() {
    if (widget.report != null && widget.reportVariation == null) {
      if (widget.report!.stockQty != null) {
        manageStock = true;
        quantity = widget.report!.stockQty!;
      } else if (widget.report!.stockQty == null) {
        if (widget.report!.status == "out of stock") {
          quantity = 0;
        } else {
          quantity = 999;
        }
      }
      name = widget.report!.name!;
      status = widget.report!.status!;
      newStatus = widget.report!.productStatus!;
      stock = widget.report!.stockQty == null
          ? widget.report!.stockStatus!
          : "${widget.report!.stockQty} pcs";

      if (newStatus == "publish") {
        newStatus = "Publish";
      } else if (newStatus == "pending") {
        newStatus = "Pending";
      } else if (newStatus == "draft") {
        newStatus = "Draft";
      }

      if (stock == "instock") {
        stock = "In Stock";
      } else if (stock == "outofstock") {
        stock = "Out of Stock";
      }
      quantityController = TextEditingController(text: "0");
      stockStatus = widget.report!.stockStatus!;
      formatedStockStatus = widget.report!.stockStatus!;
      if (stockStatus == "instock") {
        stockStatus = "In stock";
      } else if (stockStatus == "outofstock") {
        stockStatus = "Out of stock";
      }
      if (manageStock) {
        quantityController =
            TextEditingController(text: widget.report!.stockQty!.toString());
      }
      regPriceController =
          TextEditingController(text: widget.report!.regPrice.toString());
      salePriceController =
          TextEditingController(text: widget.report!.salePrice.toString());
      wholePriceController =
          TextEditingController(text: widget.report!.wholePrice.toString());
    }
  }

  updateStock() {
    setState(() {
      loadingSave = true;
    });
    String newStatus2 = '';

    if (newStatus == "Publish") {
      newStatus2 = "publish";
    } else if (newStatus == "Pending") {
      newStatus2 = "pending";
    } else if (newStatus == "Draft") {
      newStatus2 = "draft";
    }

    WholeSaleModel wholeSale = WholeSaleModel(
        type: "fixed",
        value: wholePriceController!.text.isEmpty
            ? 0
            : int.parse(wholePriceController!.text));
    List<Map<String, dynamic>> variations = [];
    Map<String, dynamic> data = {
      'variation_id': widget.reportVariation?.variationId,
      'manage_stock': manageStock,
      'stock_status': formatedStockStatus,
      'stock_quantity': double.parse(quantityController!.text),
      'regular_price':
          regPriceController!.text == "" ? "0" : regPriceController!.text,
      'sale_price':
          salePriceController!.text == "" ? "0" : salePriceController!.text,
      'wholesale': wholeSale,
    };

    variations.add(data);
    Provider.of<ReportsNotifier>(context, listen: false)
        .stocksUpdate(
      productId: widget.report!.id,
      type: widget.report!.type,
      manageStock: manageStock,
      stockStatus: formatedStockStatus,
      stockQty: quantityController!.text == "0"
          ? 1
          : int.parse(quantityController!.text),
      regPrice: regPriceController!.text == "" ? "0" : regPriceController!.text,
      salePrice:
          salePriceController!.text == "" ? "0" : salePriceController!.text,
      wholeSale: wholeSale,
      variations: variations,
      productStatus: newStatus2,
    )
        .then((value) {
      if (value == "success") {
        setState(() {
          loadingSave = false;
        });
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
          printLog("searchValue null");
          Provider.of<ReportsNotifier>(context, listen: false)
              .reset()
              .then((value) {
            if (value) {
              int? id;
              if (widget.reportVariation != null) {
                id = widget.report!.id!;
              }
              Provider.of<ReportsNotifier>(context, listen: false)
                  .getProducts(search: "", filter: "", productId: id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Success update product")));
            }
          });
        }
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed update product")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: widget.report!.image!,
                    placeholder: (context, url) => RevoPosLoading(),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.image_not_supported),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
            widget.isProductVariant == false
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Status",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Expanded(
                      //   flex: 3,
                      //   child: Text(
                      //     newStatus,
                      //     // style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      //     //     fontWeight: FontWeight.bold,
                      //     //     color: status == "available"
                      //     //         ? Colors.green
                      //     //         : status == "out of stock"
                      //     //             ? colorDanger
                      //     //             : Colors.orange),
                      //   ),
                      // ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          height: 50,
                          width: 50,
                          child: RevoPosDropdown(
                            borderColor: colorDisabled,
                            value: newStatus,
                            items: const [
                              "Publish",
                              "Pending",
                              "Draft",
                            ],
                            itemBuilder: (value) => DropdownMenuItem(
                                value: value, child: Text(value)),
                            onChanged: (value) {
                              setState(() {
                                newStatus = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Stock Status",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    stock,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                    onChanged: (val) {
                      setState(() {
                        manageStock = val!;
                        if (widget.report!.stockQty == null) {
                          quantity = 0;
                        }
                        quantityController!.text = quantity.toString();
                      });
                    },
                    value: manageStock,
                    activeColor: Theme.of(context).primaryColor),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                "Manage Stock",
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontSize: 14),
              )
            ]),
            const SizedBox(height: 8),
            manageStock
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Quantity",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildQuantity(),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Stock Status",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          height: 50,
                          width: 50,
                          child: RevoPosDropdown(
                            borderColor: colorDisabled,
                            value: stockStatus,
                            items: const [
                              "In stock",
                              "Out of stock",
                            ],
                            itemBuilder: (value) => DropdownMenuItem(
                                value: value, child: Text(value)),
                            onChanged: (value) {
                              String convertedValue = value
                                  .toString()
                                  .toLowerCase()
                                  .replaceAll(' ', '');
                              setState(() {
                                stockStatus = value;
                                formatedStockStatus = convertedValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Regular Price",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    child: RevoPosTextField(
                      controller: regPriceController!,
                      maxLines: 1,
                      hintText: "0",
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          if (value.isNotEmpty) {}
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Sale Price",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    child: RevoPosTextField(
                      controller: salePriceController!,
                      maxLines: 1,
                      hintText: "0",
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          if (value.isNotEmpty) {}
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Visibility(
              visible: Provider.of<DetailOrderNotifier>(context, listen: false)
                  .userSetting!
                  .wholesale!,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Wholesale price",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 12),
                        child: RevoPosTextField(
                          controller: wholePriceController!,
                          maxLines: 1,
                          hintText: "0",
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              if (value.isNotEmpty) {}
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: loadingSave
                  ? CircularProgressIndicator(
                      color: colorPrimary,
                    )
                  : FractionallySizedBox(
                      widthFactor: 0.5,
                      child: RevoPosButton(
                          text: "Save",
                          textColor: colorBlack,
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () {
                            updateStock();
                          }),
                    ),
            )
          ],
        ),
      ),
    ]);
  }

  Widget _buildQuantity() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RevoPosIconButton(
            icon: Icons.remove,
            color:
                quantity > 1 ? Theme.of(context).primaryColor : colorDisabled,
            onPressed: () {
              setState(() {
                if (quantity > 1) {
                  quantity = quantity - 1;
                  quantityController!.text = "$quantity";
                }
              });
            },
          ),
          Container(
            width: 85,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: RevoPosTextField(
              controller: quantityController!,
              maxLines: 1,
              hintText: "0",
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    quantity = int.parse(value);
                  }
                });
              },
            ),
          ),
          RevoPosIconButton(
            icon: Icons.add,
            onPressed: () {
              setState(() {
                quantity = quantity + 1;
                quantityController!.text = "$quantity";
              });
            },
          ),
        ],
      );
}
