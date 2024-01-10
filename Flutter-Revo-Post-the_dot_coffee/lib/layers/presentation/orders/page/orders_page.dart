import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/customers/widget/item_customer.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/widget/drawer_main.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/orders_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/widget/item_transactions.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:shimmer/shimmer.dart';

import '../../revo_pos_tab_bar.dart';
import '../../revo_pos_text_field.dart';
import 'detail_order_page.dart';

class OrdersPage extends StatefulWidget {
  final bool? menu;
  const OrdersPage({Key? key, this.menu}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  late TextEditingController transactionsController;
  late TabController tabController;

  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  OrdersNotifier? ordersNotifier;

  var tabs = [
    "All Transactions",
    "Pending Payment",
    "On Hold",
    "Processing",
    "Completed",
    "Canceled"
  ];

  @override
  void initState() {
    super.initState();
    transactionsController = TextEditingController();
    tabController =
        TabController(length: 6, vsync: this, animationDuration: Duration.zero);
    ordersNotifier = Provider.of<OrdersNotifier>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          context.read<OrdersNotifier>().tempList!.length % 10 == 0) {
        debugPrint("Load Data From Scroll");
        if (!ordersNotifier!.isLoading) {
          loadData();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkValidateCookie();
      context.read<OrdersNotifier>().resetPage();
      context.read<OrdersNotifier>().setSelectedStatus(tabController.index);
      tabController.addListener(() {
        debugPrint("Load Data From Tab");
        setState(() {});
        context.read<OrdersNotifier>().resetPage();
        setState(() {});
        context.read<OrdersNotifier>().setSelectedStatus(tabController.index);

        loadData();
        printLog("index tab : ${tabController.index}");
      });
      debugPrint("Load Data From Init");
      loadData();
    });
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

  loadData() {
    context
        .read<OrdersNotifier>()
        .getOrders(search: transactionsController.text);
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      context.read<OrdersNotifier>().resetPage();
      log(query);
      context.read<OrdersNotifier>().getOrders(search: query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMenu = context.select((MainNotifier n) => n.selected);
    final menus = context.select((MainNotifier n) => n.menus);
    final isLoading = context.select((OrdersNotifier n) => n.isLoading);
    final orders = context.select((OrdersNotifier n) => n.orders);
    final page = context.select((OrdersNotifier n) => n.orderPage);
    final tempList = context.select((OrdersNotifier n) => n.tempList);

    printLog("cek : $isLoading + $page");

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          RevoPosTabBar(
            controller: tabController,
            isScrollable: true,
            items: tabs,
            itemBuilder: (value) => Tab(child: Text(value)),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: Consumer<OrdersNotifier>(
            builder: (context, value, child) => TabBarView(
              controller: tabController,
              children: tabs
                  .map((e) => _buildList(
                      isLoading: value.isLoading,
                      page: value.orderPage,
                      order: value.orders))
                  .toList(),
            ),
          )),
          if (page != 1 && tempList!.length % 10 == 0 && isLoading)
            Center(
              child: CircularProgressIndicator(
                color: colorPrimary,
              ),
            ),
          const SizedBox(height: 5),
        ],
      ),
      drawer: DrawerMain(menus: menus, selected: selectedMenu),
    );
  }

  Widget _buildList(
      {List<Orders?>? order, required bool isLoading, required int page}) {
    order ??= List.generate(8, (index) => null);

    if (isLoading && page == 1) {
      return ListView.separated(
        itemCount: 8,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemBuilder: (_, index) {
          return Shimmer.fromColors(
              baseColor: colorDisabled,
              highlightColor: colorWhite,
              child: ItemCustomer(
                onTap: () {},
              ));
        },
        separatorBuilder: (_, index) => const SizedBox(height: 12),
      );
    }

    return order.isEmpty
        ? const Center(
            child: Text(
              'No Transactions',
              style: TextStyle(fontSize: 18),
            ),
          )
        : ListView.separated(
            itemCount: order.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            controller: _scrollController,
            itemBuilder: (_, index) => ItemTransactions(
              orders: order![index],
              onTap: () async {
                await Navigator.push(
                    context,
                    RevoPosRouteBuilder.routeBuilder(DetailOrderPage(
                      orders: order![index],
                    ))).then((value) {
                  if (value == 200) {
                    setState(() {
                      tabController.animateTo(
                          context.read<OrdersNotifier>().selectedStatus);
                    });
                  }
                });
              },
            ),
            separatorBuilder: (_, index) => const SizedBox(height: 12),
          );
  }

  _buildAppBar() => AppBar(
        backgroundColor: colorWhite,
        elevation: 0,
        leading: widget.menu!
            ? Builder(
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
              )
            : Container(
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: colorBlack),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
        title: SizedBox(
          height: 36,
          child: RevoPosTextField(
              formsearch: true,
              controller: transactionsController,
              hintText: "Search orders",
              maxLines: 1,
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
              suffixIcon: transactionsController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          transactionsController.clear();
                        });
                        _onSearchChanged("");
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: colorPrimary,
                      ),
                    )
                  : null,
              onChanged: _onSearchChanged),
        ),
      );
}
