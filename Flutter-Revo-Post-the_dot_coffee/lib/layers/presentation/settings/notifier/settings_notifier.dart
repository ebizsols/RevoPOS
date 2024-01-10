import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/domain/entities/login.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';
import 'package:revo_pos/layers/domain/entities/user_setting.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';

class SettingsNotifier with ChangeNotifier {
  String? ipAddress = "";

  bool? connected;
  BluetoothDevice? device;
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  updateIp(value) {
    ipAddress = value;
    AppConfig.data!.setString('ip', ipAddress!);
    notifyListeners();
  }

  updateBluetooth(value) {
    device = value;
    notifyListeners();
  }

  void tesPrint(Login? user, Orders? orders, context) async {
    String customerName =
        "${orders!.billing!.firstName!} ${orders.billing?.lastName != null ? orders.billing!.lastName : ' '}";
    int totalQty = 0;
    double totalPrice = 0;
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT
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
        bluetooth.printCustom("Customer    :  ${customerName}", 0, 0);
        bluetooth.printCustom("Order ID    :  #${orders.id}", 0, 0);
        bluetooth.printCustom(
            "-----------------------------------------------", 0, 0);
        for (int i = 0; i < orders.lineItems!.length; i++) {
          var jml =
              orders.lineItems![i].price! * orders.lineItems![i].quantity!;
          totalQty = totalQty + orders.lineItems![i].quantity!;
          totalPrice = totalPrice + jml;
          if (orders.lineItems![i].productName!.length <= 35) {
            bluetooth.printCustom(orders.lineItems![i].productName!, 0, 0);
          } else if (orders.lineItems![i].productName!.length > 35 &&
              orders.lineItems![i].productName!.length <= 70) {
            bluetooth.printCustom(
                orders.lineItems![i].productName!.substring(0, 34), 0, 0);
            bluetooth.printCustom(
                orders.lineItems![i].productName!.substring(34), 0, 0);
          } else {
            bluetooth.printCustom(
                orders.lineItems![i].productName!.substring(0, 34), 0, 0);
            bluetooth.printCustom(
                orders.lineItems![i].productName!.substring(34, 69), 0, 0);
            bluetooth.printCustom(
                orders.lineItems![i].productName!.substring(69), 0, 0);
          }

          bluetooth.print3Column(
              "${MultiCurrency.convert(orders.lineItems![i].price!, context)} X ${orders.lineItems![i].quantity!} pcs",
              "",
              "${MultiCurrency.convert(jml.toDouble(), context)}",
              0,
              format: "%-20s %10s %10s %n");
        }
        bluetooth.printCustom(
            "-----------------------------------------------", 0, 0);
        bluetooth.print3Column(
            "Total Qty = $totalQty",
            "",
            MultiCurrency.convert(double.parse(orders.subTotalItems!), context),
            0,
            format: "%-20s %10s %10s %n");
        bluetooth.printNewLine();
        bluetooth.print3Column("Shipping", "", "", 0,
            format: "%-20s %10s %10s %n");
        if (orders.shippingLines!.isNotEmpty) {
          if (orders.shippingLines![0].serviceName!.length < 10) {
            bluetooth.print3Column(
                "${orders.shippingLines![0].serviceName}",
                "",
                "${MultiCurrency.convert(double.parse(orders.shippingTotal!), context)}",
                0,
                format: "%-20s %10s %10s %n");
          } else {
            bluetooth.print3Column(
                "${orders.shippingLines![0].serviceName}",
                "",
                "${MultiCurrency.convert(double.parse(orders.shippingTotal!), context)}",
                0,
                format: "%-28s %2s %10s %n");
          }
        } else {
          bluetooth.print3Column(
              "-",
              "",
              "${MultiCurrency.convert(double.parse(orders.shippingTotal!), context)}",
              0,
              format: "%-20s %2s %10s %n");
        }

        if (orders.discountTotal != "0.0") {
          printLog(json.encode(orders));
          bluetooth.print3Column(
              "Coupon",
              "",
              "- ${MultiCurrency.convert(double.parse(orders.discountTotal!), context)}",
              0,
              format: "%-20s %10s %10s %n");
        }

        if (orders.totalTax != "0") {
          bluetooth.print3Column(
              "Tax",
              "",
              "${MultiCurrency.convert(double.parse(orders.totalTax!), context)}",
              0,
              format: "%-20s %10s %10s %n");
        }
        bluetooth.print3Column("Grand Total", "",
            "${MultiCurrency.convert(double.parse(orders.total!), context)}", 0,
            format: "%-20s %10s %10s %n");
        if (orders.paymentMethodTitle != "") {
          if (orders.paymentMethodTitle!.length < 10) {
            bluetooth.print3Column(
                "Payment Method", "", "${orders.paymentMethodTitle}", 0,
                format: "%-20s %10s %10s %n");
          } else {
            bluetooth.print3Column(
                "Payment Method", "", "${orders.paymentMethodTitle}", 0,
                format: "%-12s %7s %10s %n");
          }
        } else {
          bluetooth.print3Column("Payment Method", "", "-", 0,
              format: "%-20s %10s %10s %n");
        }

        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom(dateFormater(date: orders.dateCreated!), 0, 1);
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

  void printPackingSlipBlue(Orders order, UserSetting? userSetting) async {
    int totalQty = 0;
    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        bluetooth.printNewLine();
        bluetooth.printCustom("${storeName}", 2, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "===============================================", 0, 0);
        bluetooth.printCustom(dateFormater(date: order.dateCreated!), 0, 0);
        order.shippingLines!.isNotEmpty
            ? bluetooth.printCustom(
                "SHIPPING METHOD: ${order.shippingLines?[0].serviceName}", 0, 0)
            : bluetooth.printCustom("SHIPPING METHOD: -", 0, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("RECIPIENT:", 0, 0);
        bluetooth.printCustom(
            "${order.shipping?.firstName} ${order.shipping?.lastName}", 0, 0);
        bluetooth.printCustom("${order.billing?.phone}", 0, 0);
        bluetooth.printCustom(
            "${order.shipping?.firstAddress == "" ? "-" : order.shipping?.firstAddress} ${order.shipping?.secondAddress != '' ? "(${order.shipping?.secondAddress})," : " "}",
            0,
            0);
        bluetooth.printCustom(
            "${order.shipping?.city == "" ? "-" : order.shipping?.city}, ${order.shipping?.state == "" ? "-" : order.shipping?.state}, ${order.shipping?.postCode == "" ? "-" : order.shipping?.postCode}, ${order.shipping?.country == "" ? "-" : order.shipping?.country}",
            0,
            0);
        bluetooth.printNewLine();
        bluetooth.printCustom("SENDER: ", 0, 0);
        bluetooth.printCustom(storeName, 0, 0);
        bluetooth.printCustom(
            "${userSetting?.wa?.description != null ? userSetting?.wa?.description : "-"}",
            0,
            0);
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "===============================================", 0, 0);
        bluetooth.printCustom("LIST ORDER", 0, 1);
        bluetooth.printCustom(
            "===============================================", 0, 0);
        bluetooth.printNewLine();
        order.lineItems?.forEach((element) {
          bluetooth.printCustom(
            "${element.quantity} - ${element.productName}",
            0,
            0,
          );
          if (element.quantity != null) {
            totalQty += element.quantity!;
          }
        });
        bluetooth.printNewLine();
        bluetooth.printCustom("TOTAL ITEM : $totalQty", 0, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "===============================================", 0, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "NOTES: ${order.customerNote == "" ? "-" : order.customerNote}",
            0,
            0);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "  WAREHOUSE          DRIVER         RECEIVED BY", 0, 0);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

  loadBluetooth() {
    if (AppConfig.data!.containsKey('bluetooth')) {
      connected = AppConfig.data!.getBool('bluetooth');
    }
  }

  loadIp() {
    if (AppConfig.data!.containsKey('ip')) {
      ipAddress = AppConfig.data!.getString('ip');
    }
    notifyListeners();
  }
}
