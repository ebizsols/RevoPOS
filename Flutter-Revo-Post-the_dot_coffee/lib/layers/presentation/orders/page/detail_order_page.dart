import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/domain/entities/login.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';
import 'package:revo_pos/layers/domain/entities/user_setting.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/chat/page/chat_detail_page.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/detail_order_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/orders_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dash_line.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/revo_pos_snackbar.dart';
import 'package:revo_pos/layers/presentation/settings/notifier/settings_notifier.dart';
// import 'package:image/image.dart' as im;
// import 'package:image/src/formats/formats.dart' as formats;
// import 'package:http/http.dart' as http;

import '../../revo_pos_dialog.dart';
import '../../revo_pos_loading.dart';

class DetailOrderPage extends StatefulWidget {
  final Orders? orders;
  final int? idOrder;

  const DetailOrderPage({Key? key, this.orders, this.idOrder})
      : super(key: key);

  @override
  _DetailOrderPageState createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  Orders? order;
  var tabs = [
    "Pending Payment",
    "On Hold",
    "Processing",
    "Completed",
    "Canceled"
  ];
  DetailOrderNotifier? detailOrderNotifier;
  bool liveChat = true;
  double subTotal = 0;
  @override
  void initState() {
    super.initState();
    detailOrderNotifier =
        Provider.of<DetailOrderNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<DetailOrderNotifier>().getUserSettings().then((value) {
        liveChat = detailOrderNotifier!.userSetting!.liveChat!;
      });
      if (widget.orders != null) {
        setState(() {
          order = widget.orders;
        });
        context
            .read<DetailOrderNotifier>()
            .setSelectedStatusDetail(order!.status!);
        if (widget.orders!.customerID != 0 && widget.orders!.customerID != 1) {
          context
              .read<DetailOrderNotifier>()
              .getDetailCustomer(widget.orders!.customerID!);
        }

        subTotal = double.parse(order!.subTotalItems!);
      }
    });
  }

  //=======PRINTER SEGMENT========
  void testPrint(String printerIp, BuildContext ctx) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: 9100);

    if (res == PosPrintResult.success) {
      await printDemoReceipt(printer);
      printer.disconnect();
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res.msg),
      backgroundColor: Colors.black,
    ));
  }

  Future<void> printDemoReceipt(NetworkPrinter printer) async {
    Login? user = context.read<LoginNotifier>().user;
    bool? isDemo = context.read<StoreNotifier>().isDemo;
    printLog(isDemo.toString());
    String storeName =
        context.read<StoreNotifier>().selectedStore?.storeName == null
            ? "Receipt"
            : context.read<StoreNotifier>().selectedStore!.storeName!;
    int totalQty = 0;
    double totalPrice = 0;
    printer.text(storeName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    printer.feed(2);

    printer.row(
      [
        PosColumn(text: 'Kasir', width: 3),
        PosColumn(
          text: ":",
          width: 1,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: isDemo == false
              ? "${user!.user!.firstname} ${user.user!.lastname!}"
              : "Kasir Demo",
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ],
    );
    printer.row(
      [
        PosColumn(text: 'Customer', width: 3),
        PosColumn(
          text: ":",
          width: 1,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text:
              "${widget.orders!.billing!.firstName!} ${widget.orders!.billing?.lastName != null ? widget.orders!.billing!.lastName : ' '}",
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ],
    );

    printer.row(
      [
        PosColumn(text: 'Order ID', width: 3),
        PosColumn(
          text: ":",
          width: 1,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: "#${widget.orders!.id}",
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ],
    );

    printer.hr();

    for (var i = 0; i < widget.orders!.lineItems!.length; i++) {
      var jml = widget.orders!.lineItems![i].price! *
          widget.orders!.lineItems![i].quantity!;
      totalQty = totalQty + widget.orders!.lineItems![i].quantity!;
      totalPrice = totalPrice + jml;
      if (widget.orders!.lineItems![i].productName!.length <= 35) {
        printer.row([
          PosColumn(text: widget.orders!.lineItems![i].productName!, width: 12),
        ]);
      } else if (widget.orders!.lineItems![i].productName!.length > 35 &&
          widget.orders!.lineItems![i].productName!.length <= 70) {
        printer.row([
          PosColumn(
              text: widget.orders!.lineItems![i].productName!.substring(0, 34),
              width: 12),
        ]);
        printer.row([
          PosColumn(
              text: widget.orders!.lineItems![i].productName!.substring(34),
              width: 12),
        ]);
      } else {
        printer.row([
          PosColumn(
              text: widget.orders!.lineItems![i].productName!.substring(0, 34),
              width: 12),
        ]);
        printer.row([
          PosColumn(
              text: widget.orders!.lineItems![i].productName!.substring(34, 69),
              width: 12),
        ]);
        printer.row([
          PosColumn(
              text: widget.orders!.lineItems![i].productName!.substring(69),
              width: 12),
        ]);
      }

      printer.row([
        PosColumn(
            text:
                '${MultiCurrency.convert(widget.orders!.lineItems![i].price!.toDouble(), context)} x ${widget.orders!.lineItems![i].quantity!} pcs',
            width: 6),
        PosColumn(
            text: MultiCurrency.convert(jml.toDouble(), context),
            width: 6,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    printer.hr();

    printer.row([
      PosColumn(text: 'Total Qty = $totalQty', width: 6),
      PosColumn(
          text: MultiCurrency.convert(totalPrice, context),
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    printer.feed(1);

    if (widget.orders!.shippingLines![0].serviceName!.length < 20) {
      printer.row([
        PosColumn(
            text: "Shipping (${widget.orders!.shippingLines![0].serviceName})",
            width: 8),
        PosColumn(
            text: MultiCurrency.convert(
                double.parse(widget.orders!.shippingTotal!), context),
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    } else {
      printer.row([
        PosColumn(text: "Shipping", width: 7),
        PosColumn(
            text: '', width: 5, styles: const PosStyles(align: PosAlign.right)),
      ]);
      printer.row([
        PosColumn(
          text: "${widget.orders!.shippingLines![0].serviceName}",
          width: 8,
        ),
        PosColumn(
            text: MultiCurrency.convert(
                double.parse(widget.orders!.shippingTotal!), context),
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    printer.row([
      PosColumn(text: "Discount", width: 6),
      PosColumn(
          text: MultiCurrency.convert(
              widget.orders!.discountTotal == null
                  ? 0.0
                  : double.parse(widget.orders!.discountTotal!),
              context),
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    printer.row([
      PosColumn(text: "Grand Total", width: 6),
      PosColumn(
          text: MultiCurrency.convert(
              double.parse(widget.orders!.total!), context),
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    printer.row([
      PosColumn(text: "Payment Method", width: 6),
      PosColumn(
          text: widget.orders!.paymentMethodTitle!,
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    printer.feed(2);
    printer.text(dateFormater(date: widget.orders!.dateCreated!),
        styles: const PosStyles(align: PosAlign.center));
    printer.text('Thank you for shopping',
        styles: const PosStyles(align: PosAlign.center));
    printer.text('Having a Nice Day',
        styles: const PosStyles(align: PosAlign.center));
    printer.feed(2);
    printer.cut();
  }

  Future<void> printPackingSlip(NetworkPrinter printer) async {
    UserSetting? userSetting = context.read<DetailOrderNotifier>().userSetting;
    int totalQty = 0;

    // http.Response response = await http.get(Uri.parse(url));
    // final list = response.bodyBytes;
    // final image = formats.decodeImage(list);
    // printer.image(im.copyResize(image!, width: 612, height: 792));

    printer.text(storeName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    printer.hr(ch: "=");

    printer.feed(1);
    printer.text(
      dateFormater(date: order?.dateCreated!),
      styles: const PosStyles(bold: true),
    );
    printer.text(
      "SHIPPING METHOD: ${order?.shippingLines?[0].serviceName}",
      styles: const PosStyles(bold: true),
    );

    printer.feed(1);
    printer.text(
      "RECIPIENT: ",
      styles: const PosStyles(bold: true),
    );
    printer.text(
      "${order?.shipping?.firstName} ${order?.shipping?.lastName}",
      styles: const PosStyles(bold: true),
    );
    printer.text(
      "${order?.billing?.phone}",
      styles: const PosStyles(bold: true),
    );
    printer.text(
      "${order?.shipping?.firstAddress} ${order?.shipping?.secondAddress != '' ? "(${order?.shipping?.secondAddress})," : ","}",
      styles: const PosStyles(bold: true),
    );
    printer.text(
      "${order?.shipping?.city}, ${order?.shipping?.state}, ${order?.shipping?.postCode}, ${order?.shipping?.country}",
      styles: const PosStyles(bold: true),
    );

    printer.feed(1);
    printer.text(
      "SENDER: ",
      styles: const PosStyles(bold: true),
    );
    printer.text(
      storeName,
      styles: const PosStyles(bold: true),
    );
    printer.text(
      "${userSetting?.wa?.description}",
      styles: const PosStyles(bold: true),
    );

    printer.feed(1);
    printer.hr(ch: "=");
    printer.text(
      "LIST ORDER",
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    printer.hr(ch: "=");
    printer.feed(1);
    widget.orders?.lineItems?.forEach((element) {
      printer.text(
        "${element.quantity} - ${element.productName}",
        styles: const PosStyles(bold: true),
      );
      if (element.quantity != null) {
        totalQty += element.quantity!;
      }
    });
    printer.feed(1);
    printer.text(
      "TOTAL ITEM: $totalQty",
      styles: const PosStyles(bold: true),
    );
    printer.feed(1);
    printer.hr(ch: "=");

    printer.feed(1);
    printer.text(
      "NOTES: ${order?.customerNote ?? "-"}",
      styles: const PosStyles(bold: true),
    );

    printer.feed(4);

    printer.row([
      PosColumn(
          text: 'WAREHOUSE',
          width: 4,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'DRIVER',
          width: 4,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'RECEIVED BY',
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    printer.feed(1);
    printer.cut();
  }

  @override
  Widget build(BuildContext context) {
    final statusOrders =
        context.select((DetailOrderNotifier n) => n.selectedStatusDetail);
    final ip = context.select((SettingsNotifier n) => n.ipAddress);
    final bluetoothDevice = context.select((SettingsNotifier n) => n.device);

    return Scaffold(
      appBar: _buildAppBar(),
      body: order == null
          ? const RevoPosLoading()
          : Stack(
              children: [
                Positioned.fill(
                    child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: RevoPosDropdown(
                        color: Theme.of(context).colorScheme.secondary,
                        borderColor: Colors.transparent,
                        value: tabs[statusOrders],
                        items: tabs,
                        itemBuilder: (value) => DropdownMenuItem(
                            value: value,
                            child: Center(
                              child: Text(
                                (value as String).toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(color: colorBlack),
                              ),
                            )),
                        onChanged: (value) {
                          printLog(value);
                          if (tabs[statusOrders] != value) {
                            _showChangeStatusDialog(
                                newStatus: value, index: tabs.indexOf(value));
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Billing Details",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              const SizedBox(height: 8),
                              _buildBillingDetails(),
                              const SizedBox(height: 20),
                              Text(
                                "Shipping Details",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              const SizedBox(height: 8),
                              _buildBillingDetails(),
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Email",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${order!.billing!.email}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  )),
                                  const SizedBox(width: 20),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Phone Number",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${order!.billing!.phone}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Payment Via",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${order!.paymentMethodTitle}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      )
                                    ],
                                  )),
                                  const SizedBox(width: 20),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Shipping Method",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        order!.shippingLines!.isEmpty
                                            ? '-'
                                            : "${order!.shippingLines![0].serviceName}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      )
                                    ],
                                  ))
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Order Note",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${order!.customerNote}",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              const Divider(
                                height: 32,
                                thickness: 2,
                              ),
                              _buildProducts(),
                              _buildInfo(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Total",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                            color: colorBlack,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        MultiCurrency.convert(
                                            double.parse(order!.total!),
                                            context),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )),
                // if (selectedStatus >= 2)
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: Colors.grey[300],
                    width: RevoPosMediaQuery.getWidth(context),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              MultiCurrency.convert(
                                  double.parse(order!.total!), context),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RevoPosButton(
                              radius: 10,
                              text: "Print Invoice",
                              fontSize: 12,
                              padding: EdgeInsets.zero,
                              textColor: colorBlack,
                              color: Theme.of(context).colorScheme.secondary,
                              onPressed: () {
                                _showPrinterDialog(
                                    ip: ip, device: bluetoothDevice);
                              }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RevoPosButton(
                              radius: 10,
                              fontSize: 12,
                              padding: EdgeInsets.zero,
                              text: "Print Packing Slip",
                              onPressed: () async {
                                _showPrinterSlipDialog(
                                    ip: ip, device: bluetoothDevice);
                              }),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  _buildAppBar() {
    return AppBar(
      title: order == null ? const Text("") : Text("ORDER #${order!.id ?? ""}"),
      actions: [
        Visibility(
          visible: detailOrderNotifier!.userSetting!.liveChat!,
          child: Container(
            padding: EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () async {
                if (widget.orders!.customerID == 0 ||
                    widget.orders!.customerID == 1) {
                  printLog("masuk");
                  final snackbar =
                      SnackBar(content: Text("User account has been deleted"));
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                } else {
                  await Navigator.push(
                      context,
                      RevoPosRouteBuilder.routeBuilder(ChatDetailPage(
                        receiverID: widget.orders!.customerID!,
                        orderID: widget.orders!.id!,
                        orders: widget.orders!,
                        chatID: 0,
                        username: detailOrderNotifier!.customer!.username,
                      )));
                }
              },
              child: Row(children: [
                Image.asset(
                  'assets/images/live_chat.png',
                  height: 25,
                  width: 25,
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  _buildBillingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${order!.billing!.firstName} ${order!.billing!.lastName}",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        /*const SizedBox(height: 4),
        Text(
          order!.billing!.company ?? "-",
          style: Theme.of(context).textTheme.bodyText1,
        ),*/
        const SizedBox(height: 4),
        Text(
          order!.billing!.firstAddress ?? "-",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 4),
        Text(
          order!.billing!.city ?? "-",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 4),
        Text(
          order!.billing!.state ?? "-",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 4),
        Text(
          order!.billing!.postCode ?? "-",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }

  _buildProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
            2: IntrinsicColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            TableRow(children: [
              Column(children: [
                Text(
                  "Order",
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ]),
              Column(children: [
                Text(
                  "Quantity",
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ]),
              Column(children: [
                Text(
                  "Total",
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ]),
            ]),
          ],
        ),
        const SizedBox(height: 4),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order!.lineItems!.length,
          itemBuilder: (_, index) => Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FractionColumnWidth(.4),
              1: FractionColumnWidth(.2),
              2: FractionColumnWidth(.4),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  GestureDetector(
                    onTap: () async {
                      print(order!.lineItems![index].image!);
                      await showDialog(
                          context: context,
                          builder: (_) =>
                              buildPopUp(order!.lineItems![index].image!));
                    },
                    child: Text(
                      "${order!.lineItems![index].productName}",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  )
                ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${order!.lineItems![index].quantity}",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    MultiCurrency.convert(
                        double.parse(order!.lineItems![index].subTotal!),
                        context),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ]),
              ]),
            ],
          ),
          separatorBuilder: (_, index) => const SizedBox(height: 8),
        ),
      ],
    );
  }

  buildPopUp(String image) {
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
            imageUrl: image,
            fit: BoxFit.fill,
            placeholder: (context, url) => const RevoPosLoading(),
            errorWidget: (context, url, error) => const Icon(Icons.image)),
      ),
    );
  }

  _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: const RevoPosDashLine()),
        Row(
          children: [
            Expanded(
              child: Text(
                "Subtotal",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  MultiCurrency.convert(subTotal, context),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                "Shipping costs",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  MultiCurrency.convert(
                      double.parse(order!.shippingTotal!), context),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        /*Row(
          children: [
            Expanded(
              child: Text(
                "Tax",
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(CurrencyConverter.currency(double.parse(order!.tax)),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),*/
        double.parse(order!.discountTotal!) != 0
            ? Visibility(
                visible: double.parse(order!.discountTotal!) != 0 &&
                    order!.discountTotal != null,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Coupon : ${order!.couponLines!.first.code!.toUpperCase()}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "- ${MultiCurrency.convert(double.parse(order!.discountTotal!), context)}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  color: colorDanger,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        Visibility(
          visible: order!.totalTax != "0",
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Tax",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    MultiCurrency.convert(
                        double.parse(order!.totalTax!), context),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: const RevoPosDashLine()),
      ],
    );
  }

  _showChangeStatusDialog({required String newStatus, required int index}) {
    showDialog(
        context: context,
        builder: (_) => RevoPosDialog(
              titleIcon: FontAwesomeIcons.triangleExclamation,
              primaryColor: colorDanger,
              title: "Change Status?",
              content: "Do you want to change the status to \"$newStatus\"?",
              actions: [
                RevoPosDialogAction(
                    text: "No", onPressed: () => Navigator.pop(context)),
                RevoPosDialogAction(
                    text: "Yes",
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return const RevoPosLoading();
                          });
                      context
                          .read<OrdersNotifier>()
                          .setSelectedStatus(index + 1);
                      context.read<OrdersNotifier>().updateStatusOrder(
                          id: order!.id!,
                          onSubmit: (result, isLoading) {
                            if (!isLoading) {
                              Navigator.pop(context);
                              if (result['id'] != null) {
                                Navigator.pop(context, 200);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Status order updated"),
                                  backgroundColor: Colors.green,
                                ));
                              } else if (result['message'] != null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            }
                          });
                    })
              ],
            ));
  }

  _showPrinterDialog({String? ip = "", BluetoothDevice? device}) {
    showDialog(
        context: context,
        builder: (_) => RevoPosDialog(
              titleIcon: FontAwesomeIcons.triangleExclamation,
              primaryColor: colorDanger,
              title: "Choose Printer",
              content: "Please select one printer device",
              actions: [
                RevoPosDialogAction(
                    text: "Wifi",
                    onPressed: () {
                      Navigator.pop(context);
                      if (ip!.isNotEmpty) {
                        testPrint(ip, context);
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Printer currently not connected'),
                        ));
                      }
                    }),
                RevoPosDialogAction(
                    text: "Bluetooth",
                    onPressed: () {
                      Navigator.pop(context);
                      if (device != null) {
                        Login? user = context.read<LoginNotifier>().user;
                        String storeName = context
                                    .read<StoreNotifier>()
                                    .selectedStore
                                    ?.storeName ==
                                null
                            ? "Receipt"
                            : context
                                .read<StoreNotifier>()
                                .selectedStore!
                                .storeName!;
                        context
                            .read<SettingsNotifier>()
                            .tesPrint(user, widget.orders, context);
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Printer currently not connected'),
                        ));
                      }
                    })
              ],
            ));
  }

  _showPrinterSlipDialog({String? ip = "", BluetoothDevice? device}) {
    showDialog(
        context: context,
        builder: (_) => RevoPosDialog(
              titleIcon: FontAwesomeIcons.triangleExclamation,
              primaryColor: colorDanger,
              title: "Choose Printer",
              content: "Please select one printer device",
              actions: [
                RevoPosDialogAction(
                    text: "Wifi",
                    onPressed: () async {
                      Navigator.pop(context);
                      if (ip != null && ip.isNotEmpty) {
                        const PaperSize paper = PaperSize.mm80;
                        final profile = await CapabilityProfile.load();
                        final printer = NetworkPrinter(paper, profile);

                        final PosPrintResult res =
                            await printer.connect(ip, port: 9100);

                        if (res == PosPrintResult.success) {
                          await printPackingSlip(printer);
                          printer.disconnect();
                        }

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(res.msg),
                          backgroundColor: Colors.black,
                        ));
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Printer currently not connected'),
                        ));
                      }
                    }),
                RevoPosDialogAction(
                    text: "Bluetooth",
                    onPressed: () {
                      Navigator.pop(context);
                      if (device != null) {
                        UserSetting? userSetting =
                            context.read<DetailOrderNotifier>().userSetting;
                        String storeName = context
                                    .read<StoreNotifier>()
                                    .selectedStore
                                    ?.storeName ==
                                null
                            ? "Receipt"
                            : context
                                .read<StoreNotifier>()
                                .selectedStore!
                                .storeName!;
                        context
                            .read<SettingsNotifier>()
                            .printPackingSlipBlue(widget.orders!, userSetting);
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Printer currently not connected'),
                        ));
                      }
                    })
              ],
            ));
  }
}
