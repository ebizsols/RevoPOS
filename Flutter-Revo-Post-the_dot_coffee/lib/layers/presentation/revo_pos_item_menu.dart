import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/currency_converter.dart';
import 'package:revo_pos/core/utils/html_unescape.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';

class RevoPosItemMenu extends StatelessWidget {
  final Product? product;
  final Function() onTap;

  const RevoPosItemMenu({Key? key, required this.onTap, this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // String? productVariants;
    String? productPrices;
    List<String>? productVariants = [];

    if (product != null) {
      var variations = product!.variations;
      if (variations != null && variations.isNotEmpty) {
        //PRODUCT VARIANT
        variations.sort((a, b) => a.displayPrice!.compareTo(b.displayPrice!));

        var regularPrices =
            variations.map((e) => e.displayRegularPrice).toList();
        var prices = variations.map((e) => e.displayPrice).toList();

        // for (var element in product!.attributes!) {
        //   productVariants.add(element.options?.join(", ") ?? "");
        // }
        for (int i = 0; i < product!.attributes!.length; i++) {
          productVariants.add(product!.attributes![i].name!);
        }
        if (variations.length > 1) {
          productPrices = prices.isNotEmpty
              ? "${MultiCurrency.convert(prices.first?.toDouble() ?? 0.0, context)} - ${MultiCurrency.convert(prices.last?.toDouble() ?? 0.0, context)}"
              : "${MultiCurrency.convert(regularPrices.first?.toDouble() ?? 0.0, context)} - ${MultiCurrency.convert(regularPrices.last?.toDouble() ?? 0.0, context)}";
        } else {
          productPrices = prices.isEmpty
              ? MultiCurrency.convert(prices.first?.toDouble() ?? 0.0, context)
              : MultiCurrency.convert(
                  regularPrices.first?.toDouble() ?? 0.0, context);
        }
      } else {
        //PRODUCT SIMPLE
        if (product!.salePrice != 0 && product!.salePrice != null) {
          productPrices = Unescape.htmlToString(product!.formattedSalePrice!);
        } else {
          productPrices = Unescape.htmlToString(product!.formattedPrice!);
        }
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 8 / 5,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0)),
                      child: product == null ||
                              product?.images == null ||
                              product!.images!.isEmpty
                          ? Image.asset(
                              "assets/images/placeholder_image.png",
                              fit: BoxFit.contain,
                            )
                          : Image.network(
                              product!.images![0].src!,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        product?.name ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: productVariants.length,
                      itemBuilder: (context, i) {
                        return AutoSizeText(
                          productVariants[i],
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        );
                      }),
                  const SizedBox(height: 12),
                  AutoSizeText(
                    productPrices ?? "",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ),
            InkWell(
                onTap: onTap,
                child: Container(
                  alignment: Alignment.center,
                  width: RevoPosMediaQuery.getWidth(context),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0)),
                  ),
                  child: Text(
                    "Add to Cart",
                    style: TextStyle(
                        color: colorPrimary, fontWeight: FontWeight.bold),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
