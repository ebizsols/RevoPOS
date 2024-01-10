import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/currency_converter.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/html_unescape.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/data/models/variation_model.dart';
import 'package:revo_pos/layers/domain/entities/product_attribute.dart';
import 'package:revo_pos/layers/domain/entities/product_variation.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/payment_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_chip.dart';
import 'package:revo_pos/layers/presentation/revo_pos_icon_button.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/presentation/revo_pos_snackbar.dart';
import 'package:shimmer/shimmer.dart';

class BottomSheetProduct extends StatefulWidget {
  final Product? product;

  const BottomSheetProduct({Key? key, this.product}) : super(key: key);

  @override
  _BottomSheetProductState createState() => _BottomSheetProductState();
}

class _BottomSheetProductState extends State<BottomSheetProduct> {
  int? selected;
  int quantity = 1;

  String? strPrices;
  String? strRegularPrices;
  String? strDiscount;
  double? priceUsed;
  TextEditingController qtyController = TextEditingController();

  bool? available = false;
  ProductModel? product;
  int ctrAttr = 0;
  List<int> variantId = [];
  List<List<String>> listVariantOption = [];
  List<VariationModel> variant = [];

  @override
  void initState() {
    super.initState();
    printLog("product : ${json.encode(widget.product!)}");
    for (int i = 0; i < widget.product!.attributes!.length; i++) {
      widget.product!.attributes![i].selectedAttrValue = "";
    }

    if (widget.product!.variations != null) {
      for (int i = 0; i < widget.product!.variations!.length; i++) {
        variantOption = [];
        for (int j = 0;
            j < widget.product!.variations![i].option!.length;
            j++) {
          if (widget.product!.variations![i].option![j].value! != "") {
            variantOption.add(widget.product!.variations![i].option![j].value!);
          } else {
            variantOption.add("All");
          }
          if (i == 0) {
            variantList.add("");
          }
          variantId.add(widget.product!.variations![i].variationId!);
          tempVariantOptions +=
              widget.product!.variations![i].option![j].value!;
        }
        listVariantOption.add(variantOption);
      }
    }
    loadData();
    qtyController.text = quantity.toString();
    //initVariation();
    printLog("variant selected : ${variantOption} - ${tempVariantOptions}");
  }

  loadData() {
    if (widget.product != null) {
      var variations = widget.product!.variations;
      if (variations != null && variations.isNotEmpty) {
        variations.sort((a, b) => a.displayPrice!.compareTo(b.displayPrice!));

        var regularPrices =
            variations.map((e) => e.displayRegularPrice).toList();
        var prices = variations.map((e) => e.displayPrice).toList();

        if (selected == null) {
          if (variations.length > 1) {
            strRegularPrices =
                "${MultiCurrency.convert(regularPrices.first!.toDouble(), context)} - ${MultiCurrency.convert(regularPrices.last!.toDouble(), context)}";
            strPrices =
                "${MultiCurrency.convert(prices.first!.toDouble(), context)} - ${MultiCurrency.convert(prices.last!.toDouble(), context)}";
          } else {
            strRegularPrices =
                MultiCurrency.convert(regularPrices.first!.toDouble(), context);
            strPrices =
                MultiCurrency.convert(prices.first!.toDouble(), context);
            var discount =
                (regularPrices.first! - prices.first!) / regularPrices.first!;
            strDiscount = "${(discount * 100).toInt()}%";
          }
        } else {
          strRegularPrices = MultiCurrency.convert(
              regularPrices[selected!]!.toDouble(), context);
          strPrices =
              MultiCurrency.convert(prices[selected!]!.toDouble(), context);
          priceUsed = prices[selected!]!.toDouble();
        }
      } else {
        if (widget.product!.salePrice != 0 &&
            widget.product!.salePrice != null) {
          strPrices =
              Unescape.htmlToString(widget.product!.formattedSalePrice!);
        } else {
          strPrices = Unescape.htmlToString(widget.product!.formattedPrice!);
        }
        priceUsed = widget.product!.price!.toDouble();
        if (widget.product!.salePrice != 0) {
          var discount =
              (widget.product!.regularPrice! - widget.product!.salePrice!) /
                  widget.product!.regularPrice!;
          strDiscount = "${(discount * 100).toInt()}%";

          strRegularPrices =
              Unescape.htmlToString(widget.product!.formattedPrice!);
          strPrices =
              Unescape.htmlToString(widget.product!.formattedSalePrice!);
          priceUsed = widget.product!.salePrice!.toDouble();
        }
      }
      if (widget.product!.variations == null) {
        if (widget.product!.stockQuantity == null &&
            widget.product!.stockStatus == 'instock') {
          printLog('Available');
          qtyMax = 999;
          available = true;
        } else if (widget.product!.stockQuantity != null &&
            widget.product!.stockStatus == 'instock') {
          printLog('Available');
          qtyMax = widget.product!.stockQuantity!;
          available = true;
        } else if (widget.product!.stockStatus == 'outofstock') {
          qtyMax = 0;
          available = true;
        }
      }
      for (int i = 0; i < widget.product!.attributes!.length; i++) {
        setState(() {
          widget.product!.attributes![i].selectedAttrName =
              widget.product!.attributes![i].options?[0]['name'];
          widget.product!.attributes![i].selectedAttrValue =
              widget.product!.attributes![i].options?[0]['slug'];
        });
      }
      if (widget.product!.variations != null) {
        checkProductVariant(widget.product!);
      }
    }
  }

  bool load = false;
  String? variationName = '';
  List<VariationModel>? variation = [];
  Map<String, dynamic>? variationResult;
  bool isOutStock = false;
  bool validate = false;

  /*init variation & check if variation true*/
  initVariation() {
    if (widget.product!.attributes!.isNotEmpty &&
        widget.product!.type == 'variable') {
      widget.product!.customVariation!.forEach((element) {
        print("Variation True");
        setState(() {
          variation!.add(VariationModel(
              value: element.selectedValue, columnName: element.slug));
        });
      });
      checkProductVariant(widget.product!);
    }
    if (widget.product!.type == 'simple' &&
        widget.product!.stockQuantity != 0) {
      setState(() {
        available = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          const SizedBox(height: 20),
          Text(
            widget.product?.name ?? "",
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(color: Theme.of(context).primaryColor),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          _buildPrice(),
          const SizedBox(height: 12),
          Visibility(
            visible: widget.product!.attributes!.isNotEmpty,
            child: SizedBox(
                height: 200,
                child: SingleChildScrollView(child: _buildVariant())),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              RevoPosIconButton(
                icon: Icons.remove,
                color: quantity > 1
                    ? Theme.of(context).primaryColor
                    : colorDisabled,
                onPressed: () {
                  setState(() {
                    if (quantity > 1) {
                      quantity--;
                      qtyController.text = quantity.toString();
                    }
                  });
                },
              ),
              Expanded(
                  child: TextFormField(
                textAlign: TextAlign.center,
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    errorText: validate ? "Maksimum stock = $qtyMax" : null),
                onFieldSubmitted: (String? val) {
                  setState(() {
                    if (widget.product!.variations != null) {
                      if (qtyMax > int.parse(val!)) {
                        quantity = int.parse(val);
                        validate = false;
                      }
                    }
                    if (widget.product!.variations == null) {
                      if (qtyMax > int.parse(val!)) {
                        quantity = int.parse(val);
                        validate = false;
                        printLog("OKE");
                      }
                    }
                    if (qtyMax < int.parse(val!)) {
                      validate = true;
                      quantity = qtyMax;
                      qtyController.text = quantity.toString();
                    }
                  });
                },
                // child: Text(
                //   quantity.toString(),
                //   textAlign: TextAlign.center,
                //   style: Theme.of(context)
                //       .textTheme
                //       .headline6!
                //       .copyWith(color: colorBlack),
                // ),
              )),
              RevoPosIconButton(
                icon: Icons.add,
                color: widget.product!.variations != null && qtyMax > quantity
                    ? Theme.of(context).primaryColor
                    : widget.product!.variations == null && qtyMax > quantity
                        ? Theme.of(context).primaryColor
                        : colorDisabled,
                onPressed: () {
                  setState(() {
                    if (widget.product!.variations != null) {
                      if (qtyMax > quantity) {
                        quantity++;
                        qtyController.text = quantity.toString();
                      }
                    }
                    if (widget.product!.variations == null) {
                      if (qtyMax > quantity) {
                        quantity++;
                        qtyController.text = quantity.toString();
                      }
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          FractionallySizedBox(
            widthFactor: 1,
            child: widget.product!.type == 'variable'
                ? RevoPosButton(
                    text: "Add Cart",
                    color: !available!
                        ? colorDisabled
                        : Theme.of(context).primaryColor,
                    onPressed: () {
                      if (available!) {
                        setState(() {
                          widget.product!.priceUsed = priceUsed;
                          widget.product!.quantity = quantity;
                          product = widget.product as ProductModel?;
                        });
                        printLog(widget.product!.quantity.toString(),
                            name: 'Quantity');
                        printLog(json.encode(product!), name: 'Product Cek');
                        context.read<PaymentNotifier>().addToCart(context,
                            product: product!, onTap: (status) {
                          Navigator.pop(context);
                          context.read<PaymentNotifier>().getCart();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(status),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(
                                bottom: 60.0, left: 15, right: 15),
                            duration: const Duration(milliseconds: 500),
                          ));
                        });
                      } else if (!available!) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("out of stock"),
                          backgroundColor: Colors.black,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(
                              bottom: 60.0, left: 15, right: 15),
                          duration: Duration(milliseconds: 500),
                        ));
                      }
                    })
                : RevoPosButton(
                    text: "Add Cart",
                    color: !available!
                        ? colorDisabled
                        : Theme.of(context).primaryColor,
                    onPressed: () {
                      if (available!) {
                        setState(() {
                          widget.product!.priceUsed = priceUsed;
                          widget.product!.quantity = quantity;
                          product = widget.product as ProductModel?;
                        });
                        printLog(widget.product!.quantity.toString(),
                            name: 'Quantity');
                        context.read<PaymentNotifier>().addToCart(context,
                            product: product!, onTap: (status) {
                          Navigator.pop(context);
                          context.read<PaymentNotifier>().getCart();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(status),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(
                                bottom: 60.0, left: 15, right: 15),
                            duration: const Duration(milliseconds: 500),
                          ));
                        });
                      } else if (!available!) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("out of stock"),
                          backgroundColor: Colors.black,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(
                              bottom: 60.0, left: 15, right: 15),
                          duration: Duration(milliseconds: 500),
                        ));
                      }
                    }),
          )
        ],
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: double.infinity,
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: AspectRatio(
          aspectRatio: 1,
          child: widget.product == null ||
                  widget.product?.images == null ||
                  widget.product!.images!.isEmpty
              ? Image.asset(
                  "assets/images/placeholder_image.png",
                  fit: BoxFit.cover,
                )
              : Image.network(
                  widget.product!.images![0].src!,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildPrice() {
    return load
        ? Shimmer.fromColors(
            child: Container(
              width: double.infinity,
              //margin: EdgeInsets.only(left: 15, right: 15, top: 10),
              height: 20,
              color: Colors.white,
            ),
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!)
        : SizedBox(
            height: 40,
            child: Row(
              children: [
                if (strDiscount != null)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Text(
                      strRegularPrices ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(decoration: TextDecoration.lineThrough),
                    ),
                  ),
                Text(
                  strPrices ?? "",
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: colorBlack, fontWeight: FontWeight.bold),
                ),
                if (strDiscount != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 50,
                    height: 20,
                    decoration: BoxDecoration(
                        color: colorDanger,
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
                        strDiscount!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: colorWhite, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          );
  }

  num? variationPrice = 0;
  bool cekChoosenVariant = false;
  List<String> variantOption = [];
  List<String> variantSelected = [];
  List<String> variantList = [];
  String tempVariantOptions = "";
  String tempVariantSelected = "";
  int qtyMax = 0;

  cekQtyVariation(String variations, int index) {
    variantList.insert(index, variations);
    variantList.removeAt(index + 1);
    printLog("Variant List : ${variantList} - ${variantOption}");

    String tempList = variantList.join("");
    String tempOption = "";
    bool cekList = false;
    for (int i = 0; i < listVariantOption.length; i++) {
      tempOption = "";
      tempOption = listVariantOption[i].join("");
      if (tempList == tempOption) {
        cekList = true;
      }
    }
    printLog("Variant String : ${tempList} - ${tempOption}");
    if (cekList) {
      List<String> tempValueOption = [];
      setState(() {
        cekChoosenVariant = true;
        for (int i = 0; i < widget.product!.variations!.length; i++) {
          tempValueOption.clear();
          for (int j = 0;
              j < widget.product!.variations![i].option!.length;
              j++) {
            tempValueOption
                .add(widget.product!.variations![i].option![j].value!);
          }
          String tempValue = tempValueOption.join(""); // for checking variant
          String tempVal =
              tempValueOption.join(", "); // for selected variation name
          printLog("tempList : $tempList - tempValue : $tempValue");
          if (tempList == tempValue) {
            printLog(
                "price used : ${widget.product!.variations![i].displayPrice!.toDouble()}");
            priceUsed = widget.product!.variations![i].displayPrice!.toDouble();
            variationPrice = priceUsed;
            widget.product!.selectedVariationName = tempVal;
            widget.product!.selectedVariationId =
                widget.product!.variations![i].variationId;
            setState(() {
              if (widget.product!.variations![i].maxQty != "") {
                qtyMax = widget.product!.variations![i].maxQty;
              } else {
                qtyMax = 999;
              }
              quantity = 1;
              strPrices = MultiCurrency.convert(priceUsed!, context);
              printLog("qty : ${qtyMax.toString()}");
            });
          }
        }
      });
    } else {
      setState(() {
        cekChoosenVariant = false;
        qtyMax = 0;
        quantity = 0;
        strPrices = "Not Available";
      });
    }
  }

  /*get variant id, if product have variant*/
  checkProductVariant(Product productModel) async {
    setState(() {
      load = true;
      quantity = 1;
      qtyMax = 0;
    });
    var tempVar = [];
    productModel.customVariation!.forEach((element) {
      setState(() {
        tempVar.add(element.selectedName);
      });
    });
    print(tempVar);
    variationName = tempVar.join(", ");
    productModel.selectedVariationName = variationName;
    List<VariationModel> list = [];
    for (int i = 0; i < widget.product!.attributes!.length; i++) {
      list.add(VariationModel(
          columnName: widget.product!.attributes![i].slug,
          value: widget.product!.attributes![i].selectedAttrValue));
    }
    final products = Provider.of<PaymentNotifier>(context, listen: false);
    final Future<Map<String, dynamic>?> productResponse =
        products.checkVariation(id: productModel.id.toString(), variant: list);

    productResponse.then((value) {
      if (value!['variation_id'] != 0) {
        printLog(json.encode(value['data']), name: "variation product");
        setState(() {
          productModel.selectedVariationId = value['variation_id'];
          //FOR SELECTED NAME IN CART
          List<String> tempList = [];
          for (int i = 0; i < list.length; i++) {
            tempList.add(list[i].value!);
          }
          String temp = tempList.join(", ");
          //
          productModel.selectedVariationName = temp;
          load = false;
          variationResult = value;

          productModel.variations!.forEach((element) {
            if (element.variationId == productModel.selectedVariationId) {
              variationPrice = element.displayPrice!;
              strPrices = MultiCurrency.convert(
                  element.displayPrice!.toDouble(), context);
            }
          });
          priceUsed = value['data']['price'].toDouble();
          //FOR WHOLESALES PRICE
          if (value['data']['wholesales'] != null &&
              value['data']['wholesales'].isNotEmpty) {
            if (value['data']['wholesales'][0]['price'].isNotEmpty &&
                AppConfig.data!.getString('role') == 'wholesale_customer') {
              variationPrice =
                  double.parse(value['data']['wholesales'][0]['price']);
            }
          }
          //FOR CHECKING STOCK
          if (value['data']['stock_status'] == 'instock' &&
                  value['data']['stock_quantity'] == null ||
              value['data']['stock_quantity'] == 0 &&
                  value['data']['stock_status'] == 'instock') {
            qtyMax = 999;
            quantity = 1;
            available = true;
            isOutStock = false;
          } else if (value['data']['stock_status'] == 'outofstock') {
            print('outofstock');
            available = false;
            isOutStock = true;
            qtyMax = 0;
          } else if (value['data']['price'] == 0) {
            print('price not set');
            available = false;
            isOutStock = false;
            qtyMax = 0;
          } else {
            print('else');
            qtyMax = value['data']['stock_quantity'];
            quantity = 1;
            available = true;
            isOutStock = false;
          }
        });
      } else {
        if (mounted) {
          setState(() {
            variationPrice = 0;
            strPrices = "Variant is Not Available";
            available = false;
            load = false;
          });
        }
      }
      printLog(available.toString(), name: 'Is Available');
      printLog(isOutStock.toString(), name: 'Is Out Stock');
    });
  }

  Widget _buildVariant() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.product?.attributes?.length ?? 0,
      itemBuilder: (_, i) {
        ProductAttribute attribute = widget.product!.attributes![i];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${attribute.name} :",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: widget.product!.attributes![i].options?.length ?? 0,
                itemBuilder: (_, j) {
                  String? variation =
                      widget.product!.attributes![i].options?[j]['name'];

                  return RevoPosChip(
                    text: variation ?? "",
                    isEnabled: true,
                    isSelected: variation ==
                        widget.product!.attributes![i].selectedAttrName,
                    onTap: () {
                      setState(() {
                        widget.product!.attributes![i].selectedAttrName =
                            variation;
                        widget.product!.attributes![i].selectedAttrValue =
                            widget.product!.attributes![i].options?[j]['slug'];
                        //cekQtyVariation(variation!, i);
                        // List<VariationModel> list = [];
                        // list.add(VariationModel(
                        //     columnName: widget.product!.attributes![i].slug,
                        //     value: variation));
                        // context.read<PaymentNotifier>().checkVariation(
                        //     id: widget.product!.id.toString(), variant: list);
                        checkProductVariant(widget.product!);
                        printLog("Ctr : ${ctrAttr}");
                        if (cekChoosenVariant) {
                          available = true;
                        } else {
                          available = false;
                        }
                      });
                    },
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(width: 8),
              ),
            ),
          ],
        );
      },
      separatorBuilder: (_, index) => const SizedBox(height: 12),
    );
  }
}
