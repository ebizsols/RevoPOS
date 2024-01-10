import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/data/models/check_price_model.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/shipping_method_model.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/domain/entities/payment_gateway.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/orders_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/page/payment_page.dart';
import 'package:revo_pos/layers/presentation/pos/page/search_customer_page.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/payment_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/widget/item_product_cart.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dash_line.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dialog.dart';
import 'package:shimmer/shimmer.dart';

import '../../revo_pos_text_field.dart';

class BottomSheetCart extends StatefulWidget {
  final int? selectedVariant;

  const BottomSheetCart({Key? key, this.selectedVariant}) : super(key: key);

  @override
  _BottomSheetCartState createState() => _BottomSheetCartState();
}

class _BottomSheetCartState extends State<BottomSheetCart> {
  int? selected;
  int quantity = 1;

  TextEditingController customerController = TextEditingController();
  TextEditingController couponController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  String? couponStatus;
  PaymentNotifier? _paymentNotifier;
  @override
  void initState() {
    super.initState();
    _paymentNotifier = Provider.of<PaymentNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<PaymentNotifier>().getCart();
      // context.read<PaymentNotifier>().setCustomer(null);
      if (_paymentNotifier!.selectedCustomer != null) {
        List<LineItems> lineItems = [];
        for (int i = 0; i < _paymentNotifier!.cartProduct.length; i++) {
          lineItems.add(LineItems(
              productId: _paymentNotifier!.cartProduct[i].id,
              variationId:
                  _paymentNotifier!.cartProduct[i].selectedVariationId));
        }
        context
            .read<PaymentNotifier>()
            .checkPrice(
                userId: _paymentNotifier!.selectedCustomer!.id,
                lineItems: lineItems)
            .then((value) {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customer = context.select((PaymentNotifier n) => n.selectedCustomer);
    var grandTotal = context.select((PaymentNotifier n) => n.grandTotal);
    final payments = context.select((OrdersNotifier n) => n.payments);
    final loading = context.select((PaymentNotifier n) => n.loading);
    final decimalNum =
        int.parse(context.select((LoginNotifier n) => n.decimalNumber?.value));

    grandTotal = double.parse(grandTotal!.toStringAsFixed(decimalNum));

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildCustomer(customer: customer),
          const SizedBox(height: 12),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProducts(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: RevoPosDashLine(),
                ),
                _buildInfo(),
                const SizedBox(height: 12),
              ],
            ),
          )),
          const RevoPosDashLine(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Grand Total",
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: colorBlack),
                  ),
                ),
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
                        MultiCurrency.convert(grandTotal, context),
                        style: Theme.of(context).textTheme.headline6,
                      ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Consumer<PaymentNotifier>(
                  builder: (context, value, child) {
                    return RevoPosButton(
                        text: value.selectedShipping,
                        radius: 14,
                        fontSize: 14,
                        textColor: HexColor("#555555"),
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: () {
                          final paymentNotifier = Provider.of<PaymentNotifier>(
                              context,
                              listen: false);
                          List<LineItemsModel> lineItems = [];
                          for (var element in paymentNotifier.cartProduct) {
                            lineItems.add(LineItemsModel(
                                quantity: element.quantity,
                                productId: element.id,
                                variationId: element.selectedVariationId ?? 0));
                          }
                          if (customer != null) {
                            context
                                .read<PaymentNotifier>()
                                .getShippingMethod(
                                    userId: customer.id, lineItems: lineItems)
                                .then((value) {
                              if (value.isEmpty) {
                                _showAlert("Shipping Method",
                                    "No Shipping Method Available");
                              } else if (value.isNotEmpty) {
                                printLog(json.encode(value),
                                    name: "Shipping Method");
                                _showBottomSheet(
                                    widget: _buildBottomSheetShipping(value));
                              }
                            });
                          } else {
                            _showAlert("Shipping Method",
                                "Please add at least one product in cart first and select a customer");
                          }
                        });
                  },
                )),
                const SizedBox(width: 12),
                RevoPosButton(
                    text: "Pay Now",
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    radius: 14,
                    fontSize: 14,
                    onPressed: () {
                      _showBottomSheet(
                          widget: _buildBottomSheetPayment(
                              payments: payments!, total: grandTotal!));
                    }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCustomer({Customer? customer}) {
    final orderNotes = context.select((PaymentNotifier n) => n.orderNotes);
    final loading = context.select((PaymentNotifier n) => n.loadCoupon);
    final totalItems = context.select((PaymentNotifier n) => n.totalItems);
    final totalPrice = context.select((PaymentNotifier n) => n.totalPrice);
    final point = context.select((PaymentNotifier n) => n.point);
    String name = 'Select Customer';

    if (customer != null) {
      if (customer.firstName != null && customer.lastName != null) {
        name = "${customer.firstName} ${customer.lastName}";
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Customer",
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: colorBlack),
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    onTap: () async {
                      var customer = await Navigator.push(
                          context,
                          RevoPosRouteBuilder.routeBuilder(SearchCustomerPage(
                            price: totalPrice?.toInt(),
                          )));
                      printLog(json.encode(customer), name: "Customer");
                      if (customer != null) {
                        context.read<PaymentNotifier>().setCustomer(customer);
                        List<LineItems> lineItems = [];
                        PaymentNotifier paymentNotifier =
                            Provider.of<PaymentNotifier>(context,
                                listen: false);
                        for (int i = 0;
                            i < paymentNotifier.cartProduct.length;
                            i++) {
                          lineItems.add(LineItems(
                              productId: paymentNotifier.cartProduct[i].id,
                              variationId: paymentNotifier
                                  .cartProduct[i].selectedVariationId));
                        }
                        context
                            .read<PaymentNotifier>()
                            .checkPrice(
                                userId: customer.id, lineItems: lineItems)
                            .then((value) {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: colorDisabled),
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Visibility(
                    visible: true,
                    child: RevoPosButton(
                        text: "Coupon",
                        radius: 14,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        fontSize: 12,
                        color: totalItems == 0 || name == "Select Customer"
                            ? colorDisabled
                            : null,
                        onPressed: () {
                          if (totalItems == 0 || name == "Select Customer") {
                            _showAlert("Coupon",
                                "Please add at least one product in cart first and select a customer");
                          } else {
                            _couponBottomSheet(loading);
                          }
                        }),
                  ),
                  const SizedBox(width: 8),
                  RevoPosButton(
                      text: "Note",
                      radius: 14,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      fontSize: 12,
                      onPressed: () {
                        context.read<PaymentNotifier>().getOrderNotes();
                        noteController.text = orderNotes!;
                        _showBottomSheet(widget: _buildBottomSheetNote());
                      })
                ],
              ),
              customer != null && point == null && customer.point != null
                  ? Text(
                      "Use ${customer.point?.pointRedemption!} Points for a ${MultiCurrency.convert(double.parse(customer.point!.totalDiscount!), context)} discount on this order!")
                  : Container(),
              customer != null && point != null && customer.point != null
                  ? const Text("Discount Applied Successfully")
                  : Container(),
              customer != null && point == null && customer.point != null
                  ? GestureDetector(
                      onTap: () {
                        context
                            .read<PaymentNotifier>()
                            .applyPoint(customer.point!);
                        context.read<PaymentNotifier>().setSubtotal();
                      },
                      child: const Text(
                        "Apply Coupon",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProducts() {
    final listProduct = context.select((PaymentNotifier n) => n.cartProduct);

    printLog("List Product : ${json.encode(listProduct)}");
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: listProduct.length,
        itemBuilder: (_, index) {
          return ItemProductCart(
            product: listProduct[index],
          );
        });
  }

  Widget _buildInfo() {
    final totalPrice = context.select((PaymentNotifier n) => n.totalPrice);
    final totalItems = context.select((PaymentNotifier n) => n.totalItems);
    final selectedCoupon =
        context.select((PaymentNotifier n) => n.selectedCoupon);
    final discountAmount =
        context.select((PaymentNotifier n) => n.discountAmount);
    final selectedShipping =
        context.select((PaymentNotifier n) => n.selectedShippingMethod);
    final loading = context.select((PaymentNotifier n) => n.loading);
    final point = context.select((PaymentNotifier n) => n.point);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Total product",
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontWeight: FontWeight.normal, color: colorBlack),
                ),
              ),
              Text(
                "$totalItems items",
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: colorBlack),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Total price",
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontWeight: FontWeight.normal, color: colorBlack),
                ),
              ),
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
                      MultiCurrency.convert(totalPrice!, context),
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: colorBlack),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        point != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Points Redemption",
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.normal, color: colorBlack),
                      ),
                    ),
                    Text(
                      '-${MultiCurrency.convert(double.parse(point.totalDiscount!), context)}',
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: colorBlack),
                    ),
                  ],
                ),
              )
            : Container(),
        const SizedBox(height: 4),
        Visibility(
          visible: discountAmount != 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Discount",
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: colorDanger),
                      ),
                      selectedCoupon != null
                          ? Text(
                              selectedCoupon.code!.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: colorDanger),
                            )
                          : Text('',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: colorDanger)),
                    ],
                  ),
                ),
                Text(
                  '-${MultiCurrency.convert(discountAmount!, context)}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: colorDanger),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Visibility(
          visible: selectedShipping != null,
          child: selectedShipping != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          selectedShipping.methodTitle!,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: colorBlack),
                        ),
                      ),
                      Text(
                        MultiCurrency.convert(
                            selectedShipping.cost!.toDouble(), context),
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: colorBlack),
                      ),
                    ],
                  ),
                )
              : Container(),
        )

        /*const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Tax 5%",
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontWeight: FontWeight.normal,
                      color: colorBlack
                  ),
                ),
              ),
              Text(
                "Rp 1.600",
                style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: colorBlack
                ),
              ),
            ],
          ),
        ),*/
      ],
    );
  }

  _showBottomSheet({required Widget widget}) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: RevoPosMediaQuery.getWidth(ctx) * 0.5,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(ctx).viewInsets.bottom),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: widget,
                    ))
              ],
            );
          });
        });
  }

  _couponBottomSheet(bool loading) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: RevoPosMediaQuery.getWidth(context) * 0.5,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorWhite,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        decoration: BoxDecoration(
                          color: colorWhite,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Coupon code",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(color: colorBlack),
                              ),
                              const SizedBox(height: 4),
                              RevoPosTextField(
                                controller: couponController,
                                hintText: "Code",
                                onChanged: (value) {},
                              ),
                              const SizedBox(height: 12),
                              Text(couponStatus ?? ''),
                              const SizedBox(height: 4),
                              FractionallySizedBox(
                                widthFactor: 1,
                                child: RevoPosButton(
                                    radius: 14,
                                    fontSize: 12,
                                    color: loading ? colorDisabled : null,
                                    text: loading ? "Checking..." : "Apply",
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      final paymentNotifier =
                                          Provider.of<PaymentNotifier>(context,
                                              listen: false);
                                      List<LineItemsModel> lineItems = [];
                                      for (var element
                                          in paymentNotifier.cartProduct) {
                                        lineItems.add(LineItemsModel(
                                            quantity: element.quantity,
                                            productId: element.id,
                                            variationId:
                                                element.selectedVariationId ??
                                                    0));
                                      }

                                      await context
                                          .read<PaymentNotifier>()
                                          .applyCoupon(
                                              userId: paymentNotifier
                                                  .selectedCustomer!.id,
                                              couponCode: couponController.text,
                                              lineItem: lineItems,
                                              onSubmit: (result, load, expired,
                                                  available) {
                                                setState(() {
                                                  loading = load;
                                                  couponStatus = result;
                                                });
                                                context
                                                    .read<PaymentNotifier>()
                                                    .getCart();
                                                if (!expired && available) {
                                                  Navigator.pop(context);
                                                }
                                              });
                                      // await context
                                      //     .read<PaymentNotifier>()
                                      //     .submitCoupon(context,
                                      //         code: couponController.text,
                                      //         onSubmit: (result, load, expired,
                                      //             available) {
                                      //   setState(() {
                                      //     loading = load;
                                      //     couponStatus = result;
                                      //   });
                                      //   context
                                      //       .read<PaymentNotifier>()
                                      //       .getCart();
                                      //   if (!expired && available) {
                                      //     Navigator.pop(context);
                                      //   }
                                      // });
                                    }),
                              ),
                            ],
                          ),
                        ))
                  ],
                ));
      },
    );
  }

  Widget _buildBottomSheetNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order note",
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: colorBlack),
        ),
        const SizedBox(height: 4),
        RevoPosTextField(
          controller: noteController,
          hintText: "Note",
          maxLines: 3,
          onChanged: (value) {},
        ),
        const SizedBox(height: 12),
        FractionallySizedBox(
          widthFactor: 1,
          child: RevoPosButton(
              text: "Submit",
              onPressed: () {
                context
                    .read<PaymentNotifier>()
                    .setOrderNotes(noteController.text);
                Navigator.pop(context);
              }),
        ),
      ],
    );
  }

  Widget _buildBottomSheetShipping(List<ShippingMethodModel> shipping) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Please select a shipping method",
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: colorBlack),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shipping.length,
          itemBuilder: (_, index) => RevoPosButton(
              text: shipping[index].methodTitle,
              onPressed: () {
                context
                    .read<PaymentNotifier>()
                    .setShipping(shipping[index])
                    .then((value) {
                  if (value) {
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
                Navigator.pop(context);
                // context
                //     .read<PaymentNotifier>()
                //     .createOrder(
                //         payments[index].id, payments[index].methodTitle)
                //     .then((value) {
                //   if (value) {
                //     Navigator.push(
                //         context,
                //         RevoPosRouteBuilder.routeBuilder(PaymentPage(
                //           total: total,
                //           paymentId: payments[index].id!,
                //         )));
                //   } else {
                //     _showAlert("Order");
                //   }
                // });
              }),
          separatorBuilder: (_, index) => const SizedBox(height: 8),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildBottomSheetPayment(
      {required List<PaymentGateway> payments, required double total}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Please select a payment method",
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: colorBlack),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: payments.length,
          itemBuilder: (_, index) => RevoPosButton(
              text: payments[index].methodTitle,
              onPressed: () {
                // context
                //     .read<PaymentNotifier>()
                //     .createOrder(
                //         payments[index].id, payments[index].methodTitle)
                //     .then((value) {
                //   if (value) {
                //     Navigator.push(
                //         context,
                //         RevoPosRouteBuilder.routeBuilder(PaymentPage(
                //           total: total,
                //           paymentId: payments[index].id!,
                //         )));
                //   } else {
                //     _showAlert("Order",
                //         "Please add at least one product in cart first, select a customer, and select a shipping method");
                //   }
                // });
                context
                    .read<PaymentNotifier>()
                    .createOrderV2(
                        payments[index].id, payments[index].methodTitle)
                    .then((value) {
                  if (value) {
                    Navigator.push(
                        context,
                        RevoPosRouteBuilder.routeBuilder(PaymentPage(
                          total: total,
                          paymentId: payments[index].id!,
                        )));
                  } else {
                    _showAlert("Order",
                        "Please add at least one product in cart first, select a customer, and select a shipping method");
                  }
                });
              }),
          separatorBuilder: (_, index) => const SizedBox(height: 8),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  _showAlert(String title, String content) {
    showDialog(
        context: context,
        builder: (_) => RevoPosDialog(
              titleIcon: FontAwesomeIcons.info,
              primaryColor: Colors.amber,
              title: title,
              content: content,
              actions: [
                RevoPosDialogAction(
                    text: "Close", onPressed: () => Navigator.pop(context)),
              ],
            ));
  }

  // _showAlertOrder() {
  //   showDialog(
  //       context: context,
  //       builder: (_) => RevoPosDialog(
  //             titleIcon: FontAwesomeIcons.info,
  //             primaryColor: Colors.amber,
  //             title: "Order",
  //             content:
  //                 "Please add at least one product in cart first and select a customer",
  //             actions: [
  //               RevoPosDialogAction(
  //                   text: "Close",
  //                   onPressed: () =>
  //                       Navigator.of(context, rootNavigator: true).pop()),
  //             ],
  //           ));
  // }
}
