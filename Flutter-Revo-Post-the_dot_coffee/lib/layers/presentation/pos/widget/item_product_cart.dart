import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/currency_converter.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/data/models/check_price_model.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/payment_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dialog.dart';
import 'package:revo_pos/layers/presentation/revo_pos_icon_button.dart';
import 'package:shimmer/shimmer.dart';

class ItemProductCart extends StatefulWidget {
  final ProductModel? product;
  const ItemProductCart({Key? key, this.product}) : super(key: key);

  @override
  _ItemProductCartState createState() => _ItemProductCartState();
}

class _ItemProductCartState extends State<ItemProductCart> {
  String variation = "";
  List<String> listVariation = [];
  PaymentNotifier? _paymentNotifier;

  @override
  void initState() {
    super.initState();
    _paymentNotifier = Provider.of<PaymentNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((PaymentNotifier n) => n.loading);
    return Container(
      padding: const EdgeInsets.all(12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: widget.product == null ||
                      widget.product?.images == null ||
                      widget.product!.images!.isEmpty
                  ? Image.asset(
                      "assets/images/placeholder_image.png",
                      fit: BoxFit.cover,
                      width: 85,
                      height: 85,
                    )
                  : Image.network(
                      widget.product!.images![0].src!,
                      fit: BoxFit.cover,
                      width: 85,
                      height: 85,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.product!.name}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Visibility(
                  visible: widget.product!.selectedVariationName != null,
                  child: Column(
                    children: [
                      Text(
                        "${widget.product!.selectedVariationName}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodyText1!.copyWith(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                _buildQuantity(),
              ],
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                loading
                    ? Shimmer.fromColors(
                        child: Container(
                          height: 20,
                          width: 50,
                          color: Colors.white,
                        ),
                        baseColor: colorDisabled,
                        highlightColor: colorWhite)
                    : Text(
                        MultiCurrency.convert(
                            widget.product!.priceUsed!, context),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                const SizedBox(height: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: RevoPosIconButton(
                      icon: FontAwesomeIcons.trashAlt,
                      color: colorDanger,
                      onPressed: () => _showDeleteDialog(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantity() => Row(
        children: [
          RevoPosIconButton(
            icon: Icons.remove,
            color: widget.product!.quantity! > 1
                ? Theme.of(context).primaryColor
                : colorDisabled,
            onPressed: () {
              printLog("id product : ${widget.product!.quantity}");
              context.read<PaymentNotifier>().decreaseQty(
                  product: widget.product!,
                  onTap: (status) {
                    if (status) {
                      context.read<PaymentNotifier>().getCart();
                      if (_paymentNotifier!.selectedCustomer != null) {
                        List<LineItems> lineItems = [];
                        for (int i = 0;
                            i < _paymentNotifier!.cartProduct.length;
                            i++) {
                          lineItems.add(LineItems(
                              productId: _paymentNotifier!.cartProduct[i].id,
                              variationId: _paymentNotifier!
                                  .cartProduct[i].selectedVariationId));
                        }
                        context
                            .read<PaymentNotifier>()
                            .checkPrice(
                                userId: _paymentNotifier!.selectedCustomer!.id,
                                lineItems: lineItems)
                            .then((value) {});
                      }
                    }
                  });
            },
          ),
          SizedBox(
            width: 40,
            child: Text(
              widget.product!.quantity!.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          RevoPosIconButton(
            icon: Icons.add,
            onPressed: () {
              printLog("id product : ${json.encode(widget.product!.quantity)}");
              context
                  .read<PaymentNotifier>()
                  .cekQty(widget.product!, widget.product!.quantity!)
                  .then((value) {
                if (value) {
                  context.read<PaymentNotifier>().increaseQty(
                      product: widget.product!,
                      onTap: (status) {
                        if (status) {
                          context.read<PaymentNotifier>().getCart();
                          if (_paymentNotifier!.selectedCustomer != null) {
                            List<LineItems> lineItems = [];
                            for (int i = 0;
                                i < _paymentNotifier!.cartProduct.length;
                                i++) {
                              lineItems.add(LineItems(
                                  productId:
                                      _paymentNotifier!.cartProduct[i].id,
                                  variationId: _paymentNotifier!
                                      .cartProduct[i].selectedVariationId));
                            }
                            context
                                .read<PaymentNotifier>()
                                .checkPrice(
                                    userId:
                                        _paymentNotifier!.selectedCustomer!.id,
                                    lineItems: lineItems)
                                .then((value) {});
                          }
                        }
                      });
                }
              });
            },
          ),
        ],
      );

  _showDeleteDialog() {
    showDialog(
        context: context,
        builder: (_) => RevoPosDialog(
              titleIcon: FontAwesomeIcons.trash,
              primaryColor: colorDanger,
              title: "Delete Item",
              content: "Do you want to delete an item?",
              actions: [
                RevoPosDialogAction(
                    text: "No", onPressed: () => Navigator.pop(context)),
                RevoPosDialogAction(
                    text: "Yes",
                    onPressed: () {
                      context.read<PaymentNotifier>().removeCartProduct(context,
                          product: widget.product!, onTap: (status) {
                        if (status.isNotEmpty) {
                          context.read<PaymentNotifier>().getCart();
                          if (_paymentNotifier!.selectedCustomer != null) {
                            List<LineItems> lineItems = [];
                            for (int i = 0;
                                i < _paymentNotifier!.cartProduct.length;
                                i++) {
                              lineItems.add(LineItems(
                                  productId:
                                      _paymentNotifier!.cartProduct[i].id,
                                  variationId: _paymentNotifier!
                                      .cartProduct[i].selectedVariationId));
                            }
                            context
                                .read<PaymentNotifier>()
                                .checkPrice(
                                    userId:
                                        _paymentNotifier!.selectedCustomer!.id,
                                    lineItems: lineItems)
                                .then((value) {});
                          }
                          Navigator.pop(context);
                        }
                      });
                    })
              ],
            ));
  }
}
