import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/customers/notifier/customers_notifier.dart';
import 'package:revo_pos/layers/presentation/customers/widget/bottom_sheet_detail_customer.dart';
import 'package:revo_pos/layers/presentation/customers/widget/item_customer.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/widget/drawer_main.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:shimmer/shimmer.dart';

import '../../revo_pos_text_field.dart';
import 'form_customer_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  TextEditingController customerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  CustomersNotifier? customersNotifier;

  @override
  void initState() {
    super.initState();
    customersNotifier = Provider.of<CustomersNotifier>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          context.read<CustomersNotifier>().tempList!.length % 10 == 0) {
        if (!customersNotifier!.isLoading) {
          loadData();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkValidateCookie();
      context.read<CustomersNotifier>().resetPage();
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
        .read<CustomersNotifier>()
        .getCustomers(search: customerController.text);
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CustomersNotifier>().resetPage();
      log(query);
      context.read<CustomersNotifier>().getCustomers(search: query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMenu = context.select((MainNotifier n) => n.selected);
    final menus = context.select((MainNotifier n) => n.menus);

    final customers = context.select((CustomersNotifier n) => n.customers);
    final isLoading = context.select((CustomersNotifier n) => n.isLoading);
    final page = context.select((CustomersNotifier n) => n.customerPage);
    final tempList = context.select((CustomersNotifier n) => n.tempList);

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildList(customers: customers, isLoading: isLoading, page: page),
            if (page != 1 && tempList!.length % 10 == 0 && isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: colorPrimary,
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
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
        title: SizedBox(
          height: 36,
          child: RevoPosTextField(
              formsearch: true,
              controller: customerController,
              hintText: "Search here",
              maxLines: 1,
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
              onChanged: _onSearchChanged),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await Navigator.push(
                        context,
                        RevoPosRouteBuilder.routeBuilder(
                            const FormCustomerPage()))
                    .then((value) {
                  if (value == 200) {
                    context.read<CustomersNotifier>().resetPage();
                    context
                        .read<CustomersNotifier>()
                        .getCustomers(search: customerController.text);
                  }
                });
              },
              icon: FaIcon(
                FontAwesomeIcons.userPlus,
                color: Theme.of(context).primaryColor,
              )),
        ],
      );

  Widget _buildList(
      {List<Customer?>? customers,
      required bool isLoading,
      required int page}) {
    customers ??= List.generate(8, (index) => null);

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

    return ListView.separated(
      itemCount: customers.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (_, index) {
        return ItemCustomer(
          customer: customers![index],
          onTap: () async {
            showBottomSheetDetail(customers![index]);
          },
        );
      },
      separatorBuilder: (_, index) => const SizedBox(height: 12),
    );
  }

  showBottomSheetDetail(Customer? customer) {
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
                child: BottomSheetDetailCustomer(
                  customer: customer,
                  onRefresh: () {
                    context.read<CustomersNotifier>().resetPage();
                    loadData();
                  },
                ))
          ],
        );
      },
    );
  }
}
