import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/currency_converter.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/html_unescape.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/domain/entities/product_attribute.dart';
import 'package:revo_pos/layers/domain/entities/product_variation.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:revo_pos/layers/presentation/products/notifier/products_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_chip.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/presentation/products/page/form_product_page.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/revo_pos_snackbar.dart';

import '../../revo_pos_dialog.dart';
import '../../revo_pos_loading.dart';

class BottomSheetDetailProduct extends StatefulWidget {
  final Product? product;

  const BottomSheetDetailProduct({Key? key, this.product}) : super(key: key);

  @override
  _BottomSheetDetailProductState createState() =>
      _BottomSheetDetailProductState();
}

class _BottomSheetDetailProductState extends State<BottomSheetDetailProduct> {
  int? selected;
  int quantity = 1;

  String? strStock;

  @override
  void initState() {
    super.initState();
    getData();
  }

  String? weight = "0", length = "0", width = "0", height = "0", price;

  void getData() {
    var variations = widget.product!.variations;

    if (variations != null && variations.isNotEmpty) {
      variations.sort((a, b) => a.displayPrice!.compareTo(b.displayPrice!));

      var regularPrices = variations.map((e) => e.displayRegularPrice).toList();
      var prices = variations.map((e) => e.displayPrice).toList();
      var weights = variations.map((e) => e.weight).toList();
      var lengths = variations.map((e) => e.dimensions!.length).toList();
      var widths = variations.map((e) => e.dimensions!.width).toList();
      var heights = variations.map((e) => e.dimensions!.height).toList();

      if (variations.length > 1) {
        price = prices.isNotEmpty
            ? "${MultiCurrency.convert((prices.first!.toDouble()), context)} - ${MultiCurrency.convert((prices.last!.toDouble()), context)}"
            : "${MultiCurrency.convert((regularPrices.first!.toDouble()), context)} - ${MultiCurrency.convert(regularPrices.last!.toDouble(), context)}";
        weight = weights.isNotEmpty
            ? "${weights.first == "" ? "0" : weights.first} - ${weights.last}"
            : "-";
        length = lengths.isNotEmpty
            ? "${lengths.first == "" ? "0" : lengths.first} - ${lengths.last}"
            : "";
        width = widths.isNotEmpty
            ? "${widths.first == "" ? "0" : widths.first} - ${widths.last}"
            : "";
        height = lengths.isNotEmpty
            ? "${heights.first == "" ? "0" : heights.first} - ${heights.last}"
            : "";
      } else {
        price = prices.isNotEmpty
            ? MultiCurrency.convert(prices.first!.toDouble(), context)
            : MultiCurrency.convert(regularPrices.first!.toDouble(), context);
        weight = weights.first;
        length = lengths.first.toString();
        width = widths.first.toString();
        height = heights.first.toString();
      }
    } else {
      price =
          widget.product!.salePrice != null && widget.product!.salePrice! > 0
              ? Unescape.htmlToString(widget.product!.formattedSalePrice!)
              : Unescape.htmlToString(widget.product!.formattedPrice!);
      weight = widget.product!.weight;
      width = widget.product!.dimensions!.width.toString();
      length = widget.product!.dimensions!.length.toString();
      height = widget.product!.dimensions!.height.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cookie = context.select((LoginNotifier n) => n.user)?.cookie;

    if (widget.product != null) {
      if (widget.product!.stockQuantity != null) {
        if (widget.product!.stockQuantity! > 1) {
          strStock = "${widget.product!.stockQuantity!} pcs";
        } else if (widget.product!.stockQuantity! > 0) {
          strStock = "${widget.product!.stockQuantity!} pc";
        }
      } else {
        strStock = widget.product!.stockStatus;
      }
    }

    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
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
                ),
                const SizedBox(height: 12),
                Text(
                  widget.product?.description ?? "",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 8),
                _buildCategory(),
                if (widget.product!.images != null &&
                    widget.product!.images!.length > 1)
                  _buildGallery(),
                const SizedBox(height: 32),
                // Row(
                //   mainAxisSize: MainAxisSize.max,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Expanded(
                //         flex: 2,
                //         child: Text(
                //           "Youtube link",
                //           style: Theme.of(context).textTheme.bodyText1,
                //         )),
                //     const SizedBox(width: 8),
                //     Expanded(
                //       flex: 3,
                //       child: Text(
                //         widget.product?.externalUrl ?? "",
                //         style: Theme.of(context).textTheme.bodyText1,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 4),
                // Row(
                //   mainAxisSize: MainAxisSize.max,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Expanded(
                //         flex: 2,
                //         child: Text(
                //           "SKU",
                //           style: Theme.of(context).textTheme.bodyText1,
                //         )),
                //     const SizedBox(width: 8),
                //     Expanded(
                //       flex: 3,
                //       child: Text(
                //         widget.product?.sku ?? "",
                //         style: Theme.of(context).textTheme.bodyText1,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 32),
                LayoutBuilder(builder: (_, constraint) {
                  // if (widget.product?.variations != null &&
                  //     widget.product!.variations!.isNotEmpty) {
                  //   return _buildVariant();
                  // } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product!.type!,
                          style:
                              Theme.of(context).textTheme.headline1!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  )),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Price",
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              widget.product?.regularPrice == null
                                  ? ""
                                  : price!,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ],
                      ),

                      // if (widget.product?.salePrice != null &&
                      //     widget.product!.salePrice! != 0 &&
                      //     widget.product!.salePrice! <
                      //         widget.product!.regularPrice!)
                      //   Column(
                      //     children: [
                      //       const SizedBox(height: 4),
                      //       Row(
                      //         mainAxisSize: MainAxisSize.max,
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Expanded(
                      //               flex: 2,
                      //               child: Text(
                      //                 "Sale price",
                      //                 style:
                      //                     Theme.of(context).textTheme.bodyText1,
                      //               )),
                      //           const SizedBox(width: 8),
                      //           Expanded(
                      //             flex: 3,
                      //             child: Text(
                      //               widget.product?.salePrice == null
                      //                   ? ""
                      //                   : Unescape.htmlToString(widget
                      //                       .product!.formattedSalePrice!),
                      //               style:
                      //                   Theme.of(context).textTheme.bodyText1,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),

                      // const SizedBox(height: 4),
                      // Row(
                      //   mainAxisSize: MainAxisSize.max,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       flex: 2,
                      //       child: Text(
                      //         "Stock status",
                      //         style: Theme.of(context).textTheme.bodyText1,
                      //       )
                      //     ),
                      //     const SizedBox(width: 8),
                      //     Expanded(
                      //       flex: 3,
                      //       child: Text(
                      //         widget.product?.status ?? "",
                      //         style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      //             color: Theme.of(context).primaryColor,
                      //             fontWeight: FontWeight.bold
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Stock",
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              strStock ?? "",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Weight",
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              weight == "0" || weight == ""
                                  ? "- kg"
                                  : "$weight kg",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Text(
                        "Dimension",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Length",
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              length == "0" || length == ""
                                  ? "- cm"
                                  : (length! + " cm"),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Width",
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              width == "0" || width == ""
                                  ? "- cm"
                                  : (width! + " cm"),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Height",
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              height == "0" || height == ""
                                  ? "- cm"
                                  : (height! + " cm"),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                  // }
                }),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
        Positioned(bottom: 0, child: _buildBottomButtons(cookie: cookie)),
      ],
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
                  "assets/images/item_dummy.png",
                  fit: BoxFit.cover,
                  width: RevoPosMediaQuery.getWidth(context) * 0.1,
                )
              : Image.network(
                  widget.product!.images![0].src!,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildCategory() {
    String? strCategories;

    if (widget.product != null) {
      widget.product!.categories?.forEach((element) {
        if (widget.product!.categories?.indexOf(element) == 0) {
          strCategories = element.name;
        } else {
          strCategories = "$strCategories, ${element.name}";
        }
      });
    }

    return Text(
      strCategories ?? "",
      style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 12),
    );
  }

  Widget _buildGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "Gallery",
          style: Theme.of(context).textTheme.headline6,
        ),
        Container(
          height: 72,
          padding: const EdgeInsets.only(top: 8),
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: widget.product?.images?.length ?? 0,
            itemBuilder: (_, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: widget.product?.images?[index].src == null ||
                          widget.product!.images![index].src!.isEmpty
                      ? Image.asset(
                          "assets/images/placeholder_image.png",
                          width: 72,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          widget.product!.images![index].src!,
                          width: 72,
                          fit: BoxFit.cover,
                        ),
                ),
              );
            },
            separatorBuilder: (_, index) => const SizedBox(width: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildVariant() {
    ProductVariation? selectedVariation;
    if (selected != null) {
      selectedVariation = widget.product?.variations?[selected!];
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.product?.attributes?.length ?? 0,
      itemBuilder: (_, index) {
        ProductAttribute attribute = widget.product!.attributes![index];

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
                itemCount: widget.product!.variations?.length ?? 0,
                itemBuilder: (_, index) {
                  ProductVariation? variation =
                      widget.product?.variations?[index];

                  return RevoPosChip(
                    text: variation?.attributes?.attributeSize ?? "",
                    isEnabled: true,
                    isSelected: index == selected,
                    onTap: () {
                      setState(() => selected = index);
                    },
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(width: 8),
              ),
            ),
            if (selectedVariation != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 72,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                              aspectRatio: 1,
                              child: selectedVariation.image?.src == null
                                  ? Image.asset(
                                      "assets/images/placeholder_image.png",
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      selectedVariation.image!.src!,
                                      fit: BoxFit.cover,
                                    )),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfo(variation: selectedVariation),
                      )
                    ],
                  )
                ],
              )
          ],
        );
      },
      separatorBuilder: (_, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildInfo({required ProductVariation variation}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  "Normal price",
                  style: Theme.of(context).textTheme.bodyText1,
                )),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                variation.displayRegularPrice == null
                    ? ""
                    : CurrencyConverter.currency(
                        variation.displayRegularPrice!),
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        ),
        if (variation.displayPrice != null &&
            variation.displayPrice! < variation.displayRegularPrice!)
          Column(
            children: [
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(
                        "Sale price",
                        style: Theme.of(context).textTheme.bodyText1,
                      )),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      variation.displayPrice == null
                          ? ""
                          : CurrencyConverter.currency(variation.displayPrice!),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  "Stock status",
                  style: Theme.of(context).textTheme.bodyText1,
                )),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                variation.isInStock != null && variation.isInStock!
                    ? "Available"
                    : "Out of stock",
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  "Total stock",
                  style: Theme.of(context).textTheme.bodyText1,
                )),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                strStock ?? "",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  "Weight",
                  style: Theme.of(context).textTheme.bodyText1,
                )),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                "${variation.weight ?? ""} kg",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Dimension",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  "Length",
                  style: Theme.of(context).textTheme.bodyText1,
                )),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                variation.dimensions?.length.toString() ?? "",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  "Width",
                  style: Theme.of(context).textTheme.bodyText1,
                )),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                variation.dimensions?.width.toString() ?? "",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  "Height",
                  style: Theme.of(context).textTheme.bodyText1,
                )),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                variation.dimensions?.height.toString() ?? "",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButtons({String? cookie}) {
    return Container(
      width: RevoPosMediaQuery.getWidth(context),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: RevoPosButton(
                text: "Edit",
                textColor: colorBlack,
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  Navigator.push(
                      context,
                      RevoPosRouteBuilder.routeBuilder(FormProductPage(
                        product: widget.product,
                        isEdit: true,
                      )));
                }),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RevoPosButton(
                text: "Delete",
                color: colorDanger,
                onPressed: () => _showDeleteDialog(cookie: cookie)),
          ),
        ],
      ),
    );
  }

  _showDeleteDialog({String? cookie}) {
    showDialog(
        context: context,
        builder: (_) => RevoPosDialog(
              titleIcon: FontAwesomeIcons.trash,
              primaryColor: colorDanger,
              title: "Delete Product",
              content: "Do you want to delete this product?",
              actions: [
                RevoPosDialogAction(
                    text: "No", onPressed: () => Navigator.pop(context)),
                RevoPosDialogAction(
                    text: "Yes",
                    onPressed: () {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => const RevoPosLoading());

                      if (widget.product != null &&
                          widget.product!.id != null &&
                          cookie != null) {
                        context
                            .read<ProductsNotifier>()
                            .deleteProduct(
                                id: widget.product!.id.toString(),
                                cookie: cookie)
                            .then((status) {
                          if (status != null && status.status == "success") {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              context.read<ProductsNotifier>().reset();
                              context.read<ProductsNotifier>().getProducts();
                            });
                            RevoPosSnackbar(
                              context: context,
                              text: "Product has been deleted successfully",
                            ).showSnackbar();
                          } else {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            RevoPosSnackbar(
                              context: context,
                              text:
                                  "There is error when trying to delete product. Try again",
                            ).showSnackbar();
                          }
                        });
                      } else {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        RevoPosSnackbar(
                          context: context,
                          text:
                              "There is error when trying to delete product. Try again",
                        ).showSnackbar();
                      }
                    })
              ],
            ));
  }
}
