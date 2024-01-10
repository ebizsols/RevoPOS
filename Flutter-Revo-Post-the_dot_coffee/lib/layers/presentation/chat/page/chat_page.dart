import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/chat/notifier/chat_notifier.dart';
import 'package:revo_pos/layers/presentation/chat/page/chat_detail_page.dart';
import 'package:revo_pos/layers/presentation/chat/widget/item_chat.dart';
import 'package:revo_pos/layers/presentation/customers/widget/bottom_sheet_detail_customer.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/widget/drawer_main.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/detail_order_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:shimmer/shimmer.dart';

import '../../revo_pos_text_field.dart';

class ChatsPage extends StatefulWidget {
  final bool? menu;
  const ChatsPage({Key? key, this.menu}) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  TextEditingController customerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {}
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkValidateCookie();
      context.read<ChatNotifier>().resetPage();
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
    context.read<ChatNotifier>().getChatLists(search: customerController.text);
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ChatNotifier>().resetPage();
      log(query);
      context.read<ChatNotifier>().getChatLists(search: query);
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

    final customers = context.select((ChatNotifier n) => n.chatLists);
    final isLoading = context.select((ChatNotifier n) => n.isLoading);
    final page = context.select((ChatNotifier n) => n.chatPage);
    final tempList = context.select((ChatNotifier n) => n.tempChatLists);

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
                    context.read<DetailOrderNotifier>().getUserSettings();
                    Navigator.pop(context);
                  },
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
      );

  Widget _buildList(
      {List<ChatLists?>? customers,
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
              child: const ItemChatShimmer());
        },
        separatorBuilder: (_, index) => const SizedBox(height: 12),
      );
    }

    return ListView.separated(
      itemCount: customers.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (_, index) {
        return customers![index]!.time != null
            ? ItemChat(
                customer: customers[index],
                onTap: () async {
                  await Navigator.push(
                      context,
                      RevoPosRouteBuilder.routeBuilder(ChatDetailPage(
                        chatID: int.parse(customers![index]!.id!),
                        receiverID: int.parse(customers[index]!.receiverId!),
                        username: customers[index]!.userName,
                      ))).then(
                    (value) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        context.read<ChatNotifier>().resetPage();
                        loadData();
                      });
                    },
                  );
                },
              )
            : Container();
      },
      separatorBuilder: (_, index) => const Divider(
        height: 2,
      ),
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
                    loadData();
                  },
                ))
          ],
        );
      },
    );
  }
}
