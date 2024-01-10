import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/html_unescape.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/place_order_model.dart';
import 'package:revo_pos/layers/domain/entities/login.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/payment_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dash_line.dart';
import 'package:provider/provider.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

//=== Printer Package====
import 'package:revo_pos/layers/presentation/settings/notifier/settings_notifier.dart';
//=======================

import '../../revo_pos_dialog.dart';
import '../../revo_pos_loading.dart';
import '../../revo_pos_text_field.dart';

class PaymentPage extends StatefulWidget {
  final double total;
  final String paymentId;

  const PaymentPage({Key? key, required this.total, required this.paymentId})
      : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late TextEditingController receivedController;
  String localIp = '';
  List<String> devices = [];
  bool isDiscovering = false;
  int found = -1;
  TextEditingController portController = TextEditingController(text: '9100');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<PaymentNotifier>().reset();
      context.read<PaymentNotifier>().setTotal(widget.total);
      // print(context.read<StoreNotifier>().selectedStore!.storeName!);
    });
    receivedController = TextEditingController();
  }

  //=======PRINTER SEGMENT========
  // Future<CheckoutModel?> checoutPrint(CheckoutModel? order) async {
  //   CheckoutModel? dataPrint = order;
  Future<PlaceOrderModel?> checoutPrint(PlaceOrderModel? order) async {
    PlaceOrderModel? dataPrint = order;
    return dataPrint;
  }

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // void tesPrintBlue(Login? user, CheckoutModel? orders) async {
  void tesPrintBlue(Login? user, PlaceOrderModel? orders) async {
    String customerName =
        "${orders!.billingAddress!.firstName!} ${orders.billingAddress?.lastName != null ? orders.billingAddress!.lastName : ' '}";
    OrderPrint? order = context.read<PaymentNotifier>().dataPrint;
    int totalQty = 0;
    double totalPrice = 0;

    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("${storeName}", 2, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "Cashier     :  ${user!.user!.firstname} ${user.user!.lastname!}",
            0,
            0);
        bluetooth.printCustom(
            "Customer    :  ${order!.billing!.firstName!} ${order.billing?.lastName != null ? order.billing!.lastName : ' '}",
            0,
            0);
        bluetooth.printCustom("Order ID    :  #${order.idOrder}", 0, 0);
        bluetooth.printCustom(
            "-----------------------------------------------", 0, 0);
        for (int i = 0; i < order.lineItem!.length; i++) {
          var jml = order.lineItem![i].price! * order.lineItem![i].qty!;
          totalQty = totalQty + order.lineItem![i].qty!;
          totalPrice = totalPrice + jml;
          if (order.lineItem![i].name!.length <= 35) {
            bluetooth.printCustom(order.lineItem![i].name!, 0, 0);
          } else if (order.lineItem![i].name!.length > 35 &&
              order.lineItem![i].name!.length <= 70) {
            bluetooth.printCustom(
                order.lineItem![i].name!.substring(0, 34), 0, 0);
            bluetooth.printCustom(order.lineItem![i].name!.substring(34), 0, 0);
          } else {
            bluetooth.printCustom(
                order.lineItem![i].name!.substring(0, 34), 0, 0);
            bluetooth.printCustom(
                order.lineItem![i].name!.substring(34, 69), 0, 0);
            bluetooth.printCustom(order.lineItem![i].name!.substring(69), 0, 0);
          }
          bluetooth.print3Column(
              "${MultiCurrency.convert(order.lineItem![i].price!.toDouble(), context)} X ${order.lineItem![i].qty!} pcs",
              "",
              "${MultiCurrency.convert(jml.toDouble(), context)}",
              0,
              format: "%-20s %10s %10s %n");
        }
        bluetooth.printCustom(
            "-----------------------------------------------", 0, 0);
        bluetooth.print3Column("Total Qty = $totalQty", "",
            "${MultiCurrency.convert(totalPrice, context)}", 0,
            format: "%-20s %10s %10s %n");
        bluetooth.printNewLine();
        bluetooth.print3Column("Shipping", "", "", 0,
            format: "%-20s %10s %10s %n");
        if (order.shippingLines!.isNotEmpty) {
          if (order.shippingLines![0].methodTitle!.length < 10) {
            bluetooth.print3Column(
                "${order.shippingLines![0].methodTitle}",
                "",
                "${MultiCurrency.convert(double.parse(order.shippingLines![0].total!), context)}",
                0,
                format: "%-20s %10s %10s %n");
          } else {
            bluetooth.print3Column(
                "${order.shippingLines![0].methodTitle}",
                "",
                "${MultiCurrency.convert(double.parse(order.shippingLines![0].total!), context)}",
                0,
                format: "%-28s %2s %10s %n");
          }
        } else {
          bluetooth.print3Column(
              "-",
              "",
              "${MultiCurrency.convert(double.parse(order.shippingLines![0].total!), context)}",
              0,
              format: "%-20s %2s %10s %n");
        }

        if (order.discount != null && order.discount != 0) {
          printLog(json.encode(orders));
          bluetooth.print3Column(
              "Coupon",
              "",
              "- ${MultiCurrency.convert(order.discount!.toDouble(), context)}",
              0,
              format: "%-20s %10s %10s %n");
        }
        bluetooth.print3Column("Grand Total", "",
            "${MultiCurrency.convert(double.parse(order.total!), context)}", 0,
            format: "%-20s %10s %10s %n");
        if (orders.paymentMethod!.title != "") {
          if (orders.paymentMethod!.title!.length < 10) {
            bluetooth.print3Column(
                "Payment Method", "", "${orders.paymentMethod!.title}", 0,
                format: "%-20s %10s %10s %n");
          } else {
            bluetooth.print3Column(
                "Payment Method", "", "${orders.paymentMethod!.title}", 0,
                format: "%-17s %7s %10s %n");
          }
        } else {
          bluetooth.print3Column("Payment Method", "", "-", 0,
              format: "%-20s %10s %10s %n");
        }
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom(dateFormater(date: order.date), 0, 1);
        bluetooth.printCustom("Thank you for shopping", 0, 1);
        bluetooth.printCustom("Having a Nice Day", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

  // void testPrint(
  //     String printerIp, BuildContext ctx, CheckoutModel? order) async {
  void testPrint(
      String printerIp, BuildContext ctx, PlaceOrderModel? order) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: 9100);

    if (res == PosPrintResult.success) {
      // DEMO RECEIPT
      await printDemoReceipt(printer, order);
      // TEST PRINT
      // await testReceipt(printer);
      printer.disconnect();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res.msg),
        backgroundColor: Colors.black,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res.msg),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  // Future<void> printDemoReceipt(
  //     NetworkPrinter printer, CheckoutModel? ordera) async {
  Future<void> printDemoReceipt(
      NetworkPrinter printer, PlaceOrderModel? ordera) async {
    Login? user = context.read<LoginNotifier>().user;
    bool? isDemo = context.read<StoreNotifier>().isDemo;
    OrderPrint? order = context.read<PaymentNotifier>().dataPrint;
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
              "${order!.billing!.firstName!} ${order.billing?.lastName != null ? order.billing!.lastName : ' '}",
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
          text: "#${order.idOrder}",
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ],
    );

    printer.hr();

    for (var i = 0; i < order.lineItem!.length; i++) {
      var jml = order.lineItem![i].price! * order.lineItem![i].qty!;
      totalQty = totalQty + order.lineItem![i].qty!;
      totalPrice = totalPrice + jml;
      if (order.lineItem![i].name!.length <= 35) {
        printer.row([
          PosColumn(text: order.lineItem![i].name!, width: 12),
        ]);
      } else if (order.lineItem![i].name!.length > 35 &&
          order.lineItem![i].name!.length <= 70) {
        printer.row([
          PosColumn(text: order.lineItem![i].name!.substring(0, 34), width: 12),
        ]);
        printer.row([
          PosColumn(text: order.lineItem![i].name!.substring(34), width: 12),
        ]);
      } else {
        printer.row([
          PosColumn(text: order.lineItem![i].name!.substring(0, 34), width: 12),
        ]);
        printer.row([
          PosColumn(
              text: order.lineItem![i].name!.substring(34, 69), width: 12),
        ]);
        printer.row([
          PosColumn(text: order.lineItem![i].name!.substring(69), width: 12),
        ]);
      }
      printer.row([
        PosColumn(
            text:
                '${MultiCurrency.convert(order.lineItem![i].price!.toDouble(), context)} x ${order.lineItem![i].qty!} pcs',
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

    printer.row([
      PosColumn(
          text: "Shipping (${order.shippingLines![0].methodTitle})", width: 7),
      PosColumn(
          text: MultiCurrency.convert(0.0.toDouble(), context),
          width: 5,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    printer.row([
      PosColumn(text: "Discount", width: 6),
      PosColumn(
          text: MultiCurrency.convert(
              order.discount == null ? 0.0 : order.discount!.toDouble(),
              context),
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    printer.row([
      PosColumn(text: "Grand Total", width: 6),
      PosColumn(
          text: MultiCurrency.convert(double.parse(order.total!), context),
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    printer.row([
      PosColumn(text: "Payment Method", width: 6),
      PosColumn(
          text: ordera!.paymentMethod!.title!,
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    printer.feed(2);
    printer.text(dateFormater(date: order.date),
        styles: const PosStyles(align: PosAlign.center));
    printer.text('Thank you for shopping',
        styles: const PosStyles(align: PosAlign.center));
    printer.text('Having a Nice Day',
        styles: const PosStyles(align: PosAlign.center));
    printer.feed(2);
    printer.cut();
  }

  @override
  Widget build(BuildContext context) {
    final total = context.select((PaymentNotifier n) => n.total);
    final changes = context.select((PaymentNotifier n) => n.changes);
    final order = context.select((PaymentNotifier n) => n.cart);
    final orderv2 = context.select((PaymentNotifier n) => n.cartV2);
    final ip = context.select((SettingsNotifier n) => n.ipAddress);
    final bluetoothDevice = context.select((SettingsNotifier n) => n.device);

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: colorWhite,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Total",
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    MultiCurrency.convert(total, context),
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontWeight: FontWeight.w900),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: RevoPosDashLine(),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMoneyReceived(total: total),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: RevoPosDashLine(),
                  ),
                  _buildMoneyChanges(changes: changes),
                ],
              )),
              FractionallySizedBox(
                widthFactor: 1,
                child: RevoPosButton(
                    text: "Submit",
                    onPressed: () {
                      bool print = false;
                      showDialog(
                          context: context,
                          builder: (_) => RevoPosDialog(
                                titleIcon: FontAwesomeIcons.print,
                                primaryColor: colorPrimary,
                                title: "Print Receipt",
                                content: "Do you want to print receipt?",
                                actions: [
                                  RevoPosDialogAction(
                                      text: "No",
                                      onPressed: () {
                                        print = false;
                                        Navigator.pop(context);
                                      }),
                                  RevoPosDialogAction(
                                      text: "Yes",
                                      onPressed: () {
                                        print = true;
                                        Navigator.pop(context);
                                      })
                                ],
                              )).then((value) {
                        // checoutPrint(order).then((value) {
                        //   showDialog(
                        //       barrierDismissible: false,
                        //       context: context,
                        //       builder: (context) {
                        //         return const RevoPosLoading();
                        //       });
                        //   context.read<PaymentNotifier>().submitOrder(
                        //       order: order,
                        //       onSubmit: (result, loading) {
                        //         printLog("order : ${json.encode(order)}");
                        //         if (!loading) {
                        //           printLog('success');
                        //           Navigator.pop(context);
                        //           if (result == 'success') {
                        //             printLog(json.encode(value), name: "Aduh");
                        //             _showAlert('success', 'Order Success');
                        //             if (print) {
                        //               _showPrinterDialog(
                        //                   device: bluetoothDevice,
                        //                   ip: ip,
                        //                   order: value);
                        //             }
                        //           } else {
                        //             _showAlert('failed', result);
                        //           }
                        //         }
                        //       });
                        // });
                        checoutPrint(orderv2).then((value) {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return const RevoPosLoading();
                              });
                          context.read<PaymentNotifier>().placeOrder(
                              order: orderv2,
                              onSubmit: (result, loading) {
                                printLog("order : ${json.encode(order)}");
                                if (!loading) {
                                  printLog('success');
                                  Navigator.pop(context);
                                  if (result == 'success') {
                                    printLog(json.encode(value), name: "Aduh");

                                    _showAlert('success', 'Order Success');
                                    if (print) {
                                      _showPrinterDialog(
                                          device: bluetoothDevice,
                                          ip: ip,
                                          order: value);
                                    }
                                  } else {
                                    _showAlert('failed', result);
                                  }
                                }
                              });
                        });
                      });
                      // print(MultiCurrency.convert(0.0.toDouble(), context));
                      // testPrint("192.168.1.100", context, order);
                      // setState(() {});
                    }),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  _buildAppBar() => AppBar();

  Widget _buildMoneyReceived({required double total}) {
    final symbol = context.select((LoginNotifier n) => n.currencySymbol);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Money received",
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        RevoPosTextField(
          controller: receivedController,
          maxLines: 1,
          hintText: Unescape.htmlToString(symbol!.symbol!),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty && double.parse(value) >= total) {
              context
                  .read<PaymentNotifier>()
                  .setChanges(double.parse(value) - total);
            } else {
              context.read<PaymentNotifier>().setChanges(0);
            }
          },
          validator: (value) {
            if (value != null && value.isEmpty) {
              return "Money received cannot be empty";
            }
            return null;
          },
        ),
      ],
    );
  }

  // _showPrinterDialog(
  //     {String? ip = "", CheckoutModel? order, BluetoothDevice? device}) {
  _showPrinterDialog(
      {String? ip = "", PlaceOrderModel? order, BluetoothDevice? device}) {
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
                        testPrint(ip, context, order);
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
                        tesPrintBlue(user, order);
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

  Widget _buildMoneyChanges({required double changes}) => Row(
        children: [
          Expanded(
            child: Text(
              "Money changes",
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.normal, color: colorBlack),
            ),
          ),
          Text(
            MultiCurrency.convert(changes, context),
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: colorBlack),
          ),
        ],
      );

  _showAlert(String type, String status) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => RevoPosDialog(
              titleIcon: type == 'success'
                  ? FontAwesomeIcons.circleCheck
                  : FontAwesomeIcons.circleExclamation,
              primaryColor: type == 'success' ? Colors.green : colorDanger,
              title: "Order",
              content: status,
              actions: [
                RevoPosDialogAction(
                    text: "Close",
                    onPressed: () {
                      if (type == 'success') {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                      }
                    }),
              ],
            ));
  }
}
