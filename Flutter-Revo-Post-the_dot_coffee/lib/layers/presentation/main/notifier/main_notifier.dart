import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/chat/page/chat_page.dart';
import 'package:revo_pos/layers/presentation/customers/page/customers_page.dart';
import 'package:revo_pos/layers/presentation/main/page/main_page.dart';
import 'package:revo_pos/layers/presentation/notifications/page/notifications_page.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/detail_order_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/page/orders_page.dart';
import 'package:revo_pos/layers/presentation/pos/page/pos_page.dart';
import 'package:revo_pos/layers/presentation/products/page/products_page.dart';
import 'package:revo_pos/layers/presentation/settings/page/settings_page.dart';

import '../../reports/page/reports_page.dart';

class MainNotifier with ChangeNotifier {
  int selected = 0;
  PackageInfo? packageInfo;
  List<MainMenu> menus = [
    MainMenu(
        icon: FontAwesomeIcons.cashRegister,
        text: "Point of Sale (POS)",
        page: const PosPage(pos: 0, nameProduct: ""),
        type: 'icon'),
    MainMenu(
        icon: FontAwesomeIcons.box,
        text: "PRODUCT",
        page: const ProductsPage(),
        type: 'icon'),
    MainMenu(
        icon: FontAwesomeIcons.users,
        text: "CUSTOMERS",
        page: const CustomersPage(),
        type: 'icon'),
    MainMenu(
        icon: FontAwesomeIcons.moneyCheckDollar,
        text: "ORDERS",
        page: const OrdersPage(
          menu: true,
        ),
        type: 'icon'),
    MainMenu(
        icon: const AssetImage("assets/images/live_chat.png"),
        text: "LIVE CHAT",
        page: const ChatsPage(
          menu: true,
        ),
        type: 'asset'),
    MainMenu(
        icon: FontAwesomeIcons.chartLine,
        text: "REPORTS",
        page: const ReportsPage(),
        type: 'icon'),
    /*MainMenu(
      icon: FontAwesomeIcons.bell,
      text: "NOTIFICATIONS",
      page: const NotificationsPage(),
    ),*/
    MainMenu(
        icon: FontAwesomeIcons.gear,
        text: "PRINTER SETTING",
        page: const SettingsPage(),
        type: 'icon'),
    MainMenu(
        icon: FontAwesomeIcons.rightFromBracket,
        text: "LOGOUT",
        page: const NotificationsPage(),
        type: 'icon'),
  ];

  setSelected(int value) {
    selected = value;
    notifyListeners();
  }

  resetMenu() {
    menus.clear();
    menus.add(
      MainMenu(
          icon: FontAwesomeIcons.cashRegister,
          text: "Point of Sale (POS)",
          page: const PosPage(pos: 0, nameProduct: ""),
          type: 'icon'),
    );
    menus.add(
      MainMenu(
          icon: FontAwesomeIcons.box,
          text: "PRODUCT",
          page: const ProductsPage(),
          type: 'icon'),
    );
    menus.add(
      MainMenu(
          icon: FontAwesomeIcons.users,
          text: "CUSTOMERS",
          page: const CustomersPage(),
          type: 'icon'),
    );
    menus.add(
      MainMenu(
          icon: FontAwesomeIcons.moneyCheckDollar,
          text: "ORDERS",
          page: const OrdersPage(
            menu: true,
          ),
          type: 'icon'),
    );
    menus.add(
      MainMenu(
          icon: const AssetImage("assets/images/live_chat.png"),
          text: "LIVE CHAT",
          page: const ChatsPage(
            menu: true,
          ),
          type: 'asset'),
    );
    menus.add(
      MainMenu(
          icon: FontAwesomeIcons.chartLine,
          text: "REPORTS",
          page: const ReportsPage(),
          type: 'icon'),
    );
    menus.add(
      MainMenu(
          icon: FontAwesomeIcons.gear,
          text: "PRINTER SETTING",
          page: const SettingsPage(),
          type: 'icon'),
    );
    menus.add(
      MainMenu(
          icon: FontAwesomeIcons.rightFromBracket,
          text: "LOGOUT",
          page: const NotificationsPage(),
          type: 'icon'),
    );
    notifyListeners();
  }

  removeReportPage(context) {
    if (Provider.of<DetailOrderNotifier>(context, listen: false)
        .userSetting!
        .liveChat!) {
      menus.removeAt(5);
    } else {
      menus.removeAt(4);
    }
    notifyListeners();
  }

  removePageChat() {
    menus.removeAt(4);
    notifyListeners();
  }

  setPackageInfo(value) {
    packageInfo = value;
    notifyListeners();
  }
}
