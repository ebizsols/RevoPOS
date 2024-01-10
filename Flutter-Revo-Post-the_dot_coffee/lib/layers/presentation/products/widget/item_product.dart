import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/currency_converter.dart';
import 'package:revo_pos/core/utils/html_unescape.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';

class ItemProduct extends StatelessWidget {
  final Product? product;
  final Function() onTap;

  const ItemProduct({Key? key, this.product, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? strVariables;
    String? strStock;

    if (product != null) {
      if (product!.stockQuantity != null) {
        if (product!.stockQuantity! > 1) {
          strStock = "${product!.stockQuantity!} pcs";
        } else if (product!.stockQuantity! > 0) {
          strStock = "${product!.stockQuantity!} pc";
        }
      } else if (product!.stockStatus == "instock") {
        strStock = "In Stock";
      } else if (product!.stockStatus == "outofstock") {
        strStock = "Out of Stock";
      }
    }

    return Card(
      color: colorWhite,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product == null ||
                                product?.images == null ||
                                product!.images!.isEmpty
                            ? Image.asset(
                                "assets/images/placeholder_image.png",
                                fit: BoxFit.cover,
                                width:
                                    RevoPosMediaQuery.getWidth(context) * 0.1,
                              )
                            : Image.network(
                                product!.images![0].src!,
                                fit: BoxFit.cover,
                                width:
                                    RevoPosMediaQuery.getWidth(context) * 0.1,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product?.name ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                  color: colorPrimary[700],
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                strStock!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        fontSize: 12,
                                        color: colorWhite,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          strVariables ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        _buildPrice(context: context),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrice({required BuildContext context}) {
    String? strPrice;

    if (product != null) {
      var variations = product!.variations;

      if (variations != null && variations.isNotEmpty) {
        variations.sort((a, b) => a.displayPrice!.compareTo(b.displayPrice!));

        var regularPrices =
            variations.map((e) => e.displayRegularPrice).toList();
        var prices = variations.map((e) => e.displayPrice).toList();

        if (variations.length > 1) {
          strPrice = prices.isNotEmpty
              ? "${MultiCurrency.convert((prices.first!.toDouble()), context)} - ${MultiCurrency.convert((prices.last!.toDouble()), context)}"
              : "${MultiCurrency.convert((regularPrices.first!.toDouble()), context)} - ${MultiCurrency.convert(regularPrices.last!.toDouble(), context)}";
        } else {
          strPrice = prices.isNotEmpty
              ? MultiCurrency.convert(prices.first!.toDouble(), context)
              : MultiCurrency.convert(regularPrices.first!.toDouble(), context);
        }
      } else {
        strPrice = product!.salePrice != null && product!.salePrice! > 0
            ? Unescape.htmlToString(product!.formattedSalePrice!)
            : Unescape.htmlToString(product!.formattedPrice!);
      }
    }

    return Text(
      strPrice ?? "",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 14),
    );
  }
}
