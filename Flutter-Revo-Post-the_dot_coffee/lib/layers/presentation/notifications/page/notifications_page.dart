import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/widget/drawer_main.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/notifications/widget/item_notification.dart';
import 'package:revo_pos/layers/presentation/orders/page/detail_order_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final selectedMenu = context.select((MainNotifier n) => n.selected);
    final menus = context.select((MainNotifier n) => n.menus);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildList(),
      drawer: DrawerMain(
        menus: menus,
        selected: selectedMenu
      ),
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
      "NOTIFICATIONS",
      style: Theme.of(context).textTheme.headline6!.copyWith(
          color: colorBlack
      ),
    ),
  );

  _buildList() => ListView.separated(
    itemCount: 4,
    itemBuilder: (_, index) => ItemNotification(
      onTap: () {
        Navigator.push(
          context,
          RevoPosRouteBuilder.routeBuilder(const DetailOrderPage())
        );
      },
    ),
    separatorBuilder: (_, index) => const SizedBox(height: 12),
  );
}
