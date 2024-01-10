import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/page/login_page.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/widget/drawer_main.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:revo_pos/layers/presentation/products/notifier/products_notifier.dart';
import 'package:revo_pos/layers/presentation/products/widget/bottom_sheet_detail_product.dart';
import 'package:revo_pos/layers/presentation/products/widget/item_product.dart';
import 'package:shimmer/shimmer.dart';

import '../../revo_pos_text_field.dart';
import 'form_product_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  TextEditingController productController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  ProductsNotifier? productsNotifier;
  @override
  void initState() {
    super.initState();
    productsNotifier = Provider.of<ProductsNotifier>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          context.read<ProductsNotifier>().tempList!.length % 10 == 0) {
        if (!productsNotifier!.isLoadingProducts) {
          context
              .read<ProductsNotifier>()
              .getProducts(search: productController.text);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkValidateCookie();
      context.read<ProductsNotifier>().reset();
      context
          .read<ProductsNotifier>()
          .getProducts(search: productController.text);
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

  @override
  void dispose() {
    _debounce?.cancel();
    productController.dispose();
    super.dispose();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ProductsNotifier>().reset();
      log(query);
      context.read<ProductsNotifier>().getProducts(search: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedMenu = context.select((MainNotifier n) => n.selected);
    final menus = context.select((MainNotifier n) => n.menus);

    final products = context.select((ProductsNotifier n) => n.products);
    final isLoadingProducts =
        context.select((ProductsNotifier n) => n.isLoadingProducts);
    final page = context.select((ProductsNotifier n) => n.page);
    final tempList = context.select((ProductsNotifier n) => n.tempList);

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1));
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            context.read<ProductsNotifier>().reset();
            context
                .read<ProductsNotifier>()
                .getProducts(search: productController.text);
          });
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildList(
                  products: products, isLoading: isLoadingProducts, page: page),
              if (page != 1 && tempList!.length % 10 == 0 && isLoadingProducts)
                Center(
                  child: CircularProgressIndicator(
                    color: colorPrimary,
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
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
              controller: productController,
              hintText: "Search here",
              maxLines: 1,
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: colorDisabled,
                ),
                onPressed: () {
                  productController.clear();
                  context.read<ProductsNotifier>().reset();
                  context.read<ProductsNotifier>().getProducts();
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
                },
              ),
              onChanged: _onSearchChanged),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    RevoPosRouteBuilder.routeBuilder(const FormProductPage()));
              },
              icon: FaIcon(
                FontAwesomeIcons.plusSquare,
                color: Theme.of(context).primaryColor,
              )),
        ],
      );

  Widget _buildList(
      {List<Product?>? products, required bool isLoading, int? page}) {
    products ??= List.generate(12, (index) => null);

    if (isLoading && page == 1) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (_, index) {
          return Shimmer.fromColors(
              baseColor: colorDisabled,
              highlightColor: colorWhite,
              child: Card(
                  color: colorWhite,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    height: 100,
                  )));
        },
        separatorBuilder: (_, index) => const SizedBox(height: 12),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (_, index) {
        return ItemProduct(
          product: products![index],
          onTap: () {
            // if (products![index]!.type == 'variable') {
            //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //     content: Text('Variable product under maintenance'),
            //     backgroundColor: Colors.black,
            //     behavior: SnackBarBehavior.floating,
            //     duration: Duration(milliseconds: 500),
            //   ));
            // } else {
            showBottomSheetDetail(product: products![index]!);
            // }
          },
        );
      },
      separatorBuilder: (_, index) => const SizedBox(height: 12),
    );
  }

  showBottomSheetDetail({required Product product}) {
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
                child: BottomSheetDetailProduct(
                  product: product,
                ))
          ],
        );
      },
    );
  }
}
