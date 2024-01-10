import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/currency_converter.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';

import 'bottom_sheet_product.dart';

class ItemProductScan extends StatefulWidget {
  final Product? product;
  final Function()? onTap;
  const ItemProductScan({Key? key, this.product, this.onTap}) : super(key: key);

  @override
  _ItemProductScanState createState() => _ItemProductScanState();
}

class _ItemProductScanState extends State<ItemProductScan> {

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1 / 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.product == null ||
                        widget.product?.images == null ||
                        widget.product!.images!.isEmpty
                    ? Image.asset(
                        "assets/images/placeholder_image.png",
                        fit: BoxFit.cover,
                        width: RevoPosMediaQuery.getWidth(context) * 0.1,
                      )
                    : Image.network(
                        widget.product!.images![0].src!,
                        fit: BoxFit.cover,
                        width: RevoPosMediaQuery.getWidth(context) * 0.1,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.product!.name!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            )),
            IconButton(
                onPressed: () {
                  _showBottomSheetDetail(product: widget.product!);
                },
                iconSize: 30,
                icon: Icon(
                  FontAwesomeIcons.cartPlus,
                  color: Theme.of(context).primaryColor,
                ))
          ],
        ),
      ),
    );
  }

  _showBottomSheetDetail(
      {required Product product}) {
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
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: BottomSheetProduct(
                product: product,
              ),
            )
          ],
        );
      },
    );
  }
}
