import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/html_unescape.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/chat/page/chat_page.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/detail_order_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/orders_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/page/orders_page.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/payment_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/page/categories_page.dart';
import 'package:revo_pos/layers/presentation/pos/page/qr_scanner_page.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_item_menu.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/widget/drawer_main.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/widget/bottom_sheet_cart.dart';
import 'package:revo_pos/layers/presentation/pos/widget/bottom_sheet_product.dart';
import 'package:revo_pos/layers/presentation/pos/widget/item_category_pos.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../revo_pos_text_field.dart';
import 'draft_page.dart';

class PosPage extends StatefulWidget {
  final int? pos;
  final String? nameProduct;
  const PosPage({Key? key, this.pos = 0, this.nameProduct = ""})
      : super(key: key);

  @override
  _PosPageState createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  PosNotifier? posNotifier;
  DetailOrderNotifier? detailOrderNotifier;
  @override
  void initState() {
    super.initState();
    posNotifier = Provider.of<PosNotifier>(context, listen: false);
    detailOrderNotifier =
        Provider.of<DetailOrderNotifier>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          context.read<PosNotifier>().tempList!.length % 10 == 0) {
        if (!posNotifier!.isLoadingProducts && widget.pos != 1) {
          context
              .read<PosNotifier>()
              .getProducts(search: searchController.text);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkValidateCookie();
      context.read<PosNotifier>().reset();
      context.read<OrdersNotifier>().resetPage();
      context.read<PosNotifier>().getCategories();
      context.read<DetailOrderNotifier>().getUserSettings();
      context.read<PosNotifier>().setIsSearch(false);
      if (widget.pos != 1) {
        context.read<PosNotifier>().getProducts();
      }
      context.read<PaymentNotifier>().getCart();
      context.read<OrdersNotifier>().getPayments();
    });

    productFromChat();
  }

  void productFromChat() {
    if (widget.pos == 1) {
      printLog("MASUK : ${widget.nameProduct!}");
      searchController.text = widget.nameProduct!;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        context.read<PosNotifier>().setIsSearch(true);
        context.read<PosNotifier>().reset();
        context.read<PosNotifier>().resetPage();
        context.read<PosNotifier>().getProducts(search: widget.nameProduct);
      });
    }
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

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      log(query);
      context.read<PosNotifier>().resetPage();
      context.read<PosNotifier>().getProducts(search: query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMenu = context.select((MainNotifier n) => n.selected);
    final menus = context.select((MainNotifier n) => n.menus);

    final categories = context.select((PosNotifier n) => n.categories);
    final isLoadingCategories =
        context.select((PosNotifier n) => n.isLoadingCategories);

    final products = context.select((PosNotifier n) => n.products);
    final isLoadingProducts =
        context.select((PosNotifier n) => n.isLoadingProducts);

    final selectedCategory =
        context.select((PosNotifier n) => n.selectedCategory);
    final isSearch = context.select((PosNotifier n) => n.isSearch);

    final selectedVariant =
        context.select((PosNotifier n) => n.selectedVariant);
    final quantity = context.select((PosNotifier n) => n.quantity);

    final totalItems = context.select((PaymentNotifier n) => n.totalItems);
    final tempList = context.select((PosNotifier n) => n.tempList);
    final page = context.select((PosNotifier n) => n.page);

    return Scaffold(
      appBar: _buildAppBar(isSearch: isSearch),
      floatingActionButton: Container(
        width: RevoPosMediaQuery.getWidth(context),
        padding: const EdgeInsets.all(12),
        child: RevoPosButton(
            radius: 14,
            fontSize: 12,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            text: "Cart ($totalItems items)",
            icon: Container(
              margin: const EdgeInsets.only(right: 8),
              child: FaIcon(
                FontAwesomeIcons.cartShopping,
                size: 16,
                color: colorWhite,
              ),
            ),
            onPressed: () => _showBottomSheetCart()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  if (!isSearch)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Categories",
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      RevoPosRouteBuilder.routeBuilder(
                                          const CategoriesPage()));
                                },
                                child: Text(
                                  "All categories",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildCategories(
                            categories: categories,
                            isLoading: isLoadingCategories,
                            selected: selectedCategory),
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${categories == null || selectedCategory == 0 ? "All" : Unescape.htmlToString(categories[selectedCategory - 1].name!)} Menu",
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                              Text(
                                "${products?.length ?? 0} All Menu Result",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  Expanded(
                      child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(Duration(seconds: 1));
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        context.read<PosNotifier>().reset();
                        context.read<OrdersNotifier>().resetPage();
                        context.read<PosNotifier>().getCategories();
                        context.read<PosNotifier>().getProducts();
                        context.read<PaymentNotifier>().getCart();
                        context.read<OrdersNotifier>().getPayments();
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: [
                              _buildMenu(
                                  products: products,
                                  isLoading: isLoadingProducts,
                                  selectedVariant: selectedVariant,
                                  quantity: quantity,
                                  page: page),
                              if (page != 1 &&
                                  tempList!.length % 10 == 0 &&
                                  isLoadingProducts)
                                Center(
                                  child: CircularProgressIndicator(
                                    color: colorPrimary,
                                  ),
                                ),
                              const SizedBox(height: 72),
                            ],
                          ),
                        )),
                  )),
                ],
              )),
        ],
      ),
      drawer: DrawerMain(menus: menus, selected: selectedMenu),
    );
  }

  _buildAppBar({required bool isSearch}) => AppBar(
        backgroundColor: colorWhite,
        elevation: 0,
        leading: isSearch
            ? BackButton(
                onPressed: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  currentFocus.unfocus();

                  printLog("is search : $isSearch");
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    context.read<PosNotifier>().setIsSearch(false);
                    searchController.clear();
                    setState(() {});
                  });
                  printLog("is search2 : $isSearch");
                  if (widget.pos != 1) {
                    context.read<PosNotifier>().reset();

                    context.read<PosNotifier>().getCategories();
                    context
                        .read<PosNotifier>()
                        .getProducts(search: searchController.text);
                  } else {
                    Navigator.pop(context);
                  }
                },
              )
            : Builder(
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
                  onPressed: () {
                    context.read<PosNotifier>().setIsSearch(false);
                    Scaffold.of(context).openDrawer();
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    currentFocus.unfocus();
                  },
                ),
              ),
        title: SizedBox(
          height: 36,
          child: RevoPosTextField(
              onTap: () {
                context.read<PosNotifier>().setIsSearch(true);
              },
              formsearch: true,
              controller: searchController,
              hintText: "Search here",
              maxLines: 1,
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  searchController.clear();
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colorDisabled,
                ),
              ),
              onChanged: _onSearchChanged),
        ),
        actions: [
          if (!isSearch)
            Visibility(
                visible: false,
                child: IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          RevoPosRouteBuilder.routeBuilder(const DraftPage()));
                    },
                    icon: Icon(
                      MdiIcons.noteEdit,
                      color: Theme.of(context).primaryColor,
                    ))),
          Visibility(
              visible: true,
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        RevoPosRouteBuilder.routeBuilder(
                            const QRScannerPage()));
                  },
                  icon: Image.asset('assets/images/barcode.png'))),
          Visibility(
              visible: true,
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => OrdersPage(
                                  menu: false,
                                ))));
                  },
                  icon: Image.asset('assets/images/list_order.png'))),
          Visibility(
              visible: detailOrderNotifier!.userSetting!.liveChat!,
              child: Stack(children: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => const ChatsPage(
                                    menu: false,
                                  )))).then((value) => context
                          .read<DetailOrderNotifier>()
                          .getUserSettings());
                    },
                    icon: Image.asset('assets/images/live_chat.png')),
                detailOrderNotifier!.userSetting!.unread! > 0
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.red),
                          child: Center(
                            child: Text(
                              detailOrderNotifier!.userSetting!.unread
                                  .toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : Container()
              ]))
        ],
      );

  Widget _buildCategories(
      {required List<Category?>? categories,
      required bool isLoading,
      required int selected}) {
    categories ??= List.generate(6, (index) => null);

    printLog(selected.toString(), name: 'Selected');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 8),
          SizedBox(
            height: 100,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              itemBuilder: (_, index) {
                if (index == 0) {
                  if (categories![index] == null || isLoading) {
                    return Shimmer.fromColors(
                      baseColor: colorDisabled,
                      highlightColor: colorWhite,
                      child: ItemCategoryPos(
                        isSelected: false,
                        image: 'asset',
                        onTap: () {},
                      ),
                    );
                  }

                  return ItemCategoryPos(
                    name: "All",
                    image: "assets/images/category_dummy_1.png",
                    isSelected: index == selected,
                    onTap: () {
                      context.read<PosNotifier>().setSelectedCategory(index, 0);
                    },
                  );
                } else {
                  if (categories![index - 1] == null || isLoading) {
                    return Shimmer.fromColors(
                      baseColor: colorDisabled,
                      highlightColor: colorWhite,
                      child: ItemCategoryPos(
                        isSelected: false,
                        onTap: () {},
                        image: 'asset',
                      ),
                    );
                  }

                  return ItemCategoryPos(
                    name: Unescape.htmlToString(categories[index - 1]!.name!),
                    image: categories[index - 1]!.image?.src,
                    isSelected: index == selected,
                    onTap: () {
                      context.read<PosNotifier>().setSelectedCategory(
                          index, categories![index - 1]!.id!);
                    },
                  );
                }
              },
              separatorBuilder: (_, index) => const SizedBox(width: 8),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMenu(
      {List<Product?>? products,
      required bool isLoading,
      int? selectedVariant,
      required int quantity,
      int? page}) {
    products ??= List.generate(12, (index) => null);

    if (isLoading && page == 1) {
      return WaterfallFlow.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
        itemCount: 6,
        itemBuilder: (_, index) {
          return Shimmer.fromColors(
            baseColor: colorDisabled,
            highlightColor: colorWhite,
            child: RevoPosItemMenu(
              onTap: () {},
            ),
          );
        },
      );
    }

    return WaterfallFlow.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemCount: products.length,
      itemBuilder: (_, index) {
        /*var strVariables = products[index]!.variables!.length > 1
        ? "${products[index]!.variables!.first.name} - ${products[index]!.variables!.last.name}"
        : products[index]!.variables!.first.name;*/

        /*var prices = products[index]!.variables!.map((e) => e.salePrice ?? e.normalPrice).toList();
        prices.sort();*/

        return RevoPosItemMenu(
          product: products![index]!,
          onTap: () => _showBottomSheetDetail(
              product: products![index]!,
              selectedVariant: selectedVariant,
              quantity: quantity),
        );
      },
    );
  }

  _showBottomSheetDetail(
      {required Product product, int? selectedVariant, required int quantity}) {
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
              child: BottomSheetProduct(
                product: product,
              ),
            )
          ],
        );
      },
    );
  }

  _showBottomSheetCart() {
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
                height: RevoPosMediaQuery.getHeight(context) - 60,
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const BottomSheetCart())
          ],
        );
      },
    );
  }
}
