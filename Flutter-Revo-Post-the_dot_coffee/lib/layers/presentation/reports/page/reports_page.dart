import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/widget/drawer_main.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/reports/page/reports_orders_page.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/reports/page/reports_stocks_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    checkValidateCookie();
  }

  newLogoutPopDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                height: 150,
                width: 330,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Your Session is expired, Please Login again",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Container(
                        child: Column(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 2,
                        ),
                        GestureDetector(
                          onTap: () => logout(),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15)),
                                color: Theme.of(context).primaryColor),
                            child: Text(
                              "Ok",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ))
                  ],
                ),
              );
            },
          )),
    );
  }

  logout() async {
    context.read<StoreNotifier>().logout().then((value) {
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, RevoPosRouteBuilder.routeBuilder(const LoginPage()));
    });
  }

  checkValidateCookie() {
    context.read<PosNotifier>().checkValidateCookie().then((value) {
      if (value.toString().contains("error")) {
        newLogoutPopDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedMenu = context.select((MainNotifier n) => n.selected);
    final menus = context.select((MainNotifier n) => n.menus);

    final selectedTab = context.select((ReportsNotifier n) => n.selectedTab);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: RevoPosButton(
                      text: "Orders",
                      textColor: selectedTab == 0
                          ? colorWhite
                          : Theme.of(context).primaryColor,
                      color: selectedTab == 0
                          ? Theme.of(context).primaryColor
                          : colorWhite,
                      elevation: 0,
                      onPressed: () {
                        context.read<ReportsNotifier>().setSelectedTab(0);
                      }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RevoPosButton(
                      text: "Stocks",
                      textColor: selectedTab == 1
                          ? colorWhite
                          : Theme.of(context).primaryColor,
                      color: selectedTab == 1
                          ? Theme.of(context).primaryColor
                          : colorWhite,
                      elevation: 0,
                      onPressed: () {
                        context.read<ReportsNotifier>().setSelectedTab(1);
                      }),
                ),
              ],
            ),
          ),
          Expanded(child: LayoutBuilder(
            builder: (_, constraint) {
              switch (selectedTab) {
                case 0:
                  return const ReportsOrdersPage();
                default:
                  return const ReportsStocksPage();
              }
            },
          ))
        ],
      ),
      drawer: DrawerMain(menus: menus, selected: selectedMenu),
    );
  }

  _buildAppBar() => AppBar(
        backgroundColor: colorWhite,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 4),
                Text(
                  "MENU",
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColor,
                      ),
                )
              ],
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "REPORTS",
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: colorBlack),
        ),
      );
}
