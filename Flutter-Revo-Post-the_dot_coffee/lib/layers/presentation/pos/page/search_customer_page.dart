import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/presentation/customers/notifier/customers_notifier.dart';
import 'package:revo_pos/layers/presentation/customers/widget/item_customer.dart';
import 'package:revo_pos/layers/presentation/pos/widget/item_search_customer.dart';
import 'package:shimmer/shimmer.dart';

import '../../revo_pos_text_field.dart';

class SearchCustomerPage extends StatefulWidget {
  final int? price;
  SearchCustomerPage({Key? key, this.price}) : super(key: key);

  @override
  _SearchCustomerPageState createState() => _SearchCustomerPageState();
}

class _SearchCustomerPageState extends State<SearchCustomerPage> {
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  CustomersNotifier? customersNotifier;

  @override
  void initState() {
    super.initState();
    customersNotifier = Provider.of<CustomersNotifier>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          context.read<CustomersNotifier>().tempList!.length % 10 == 0) {
        loadData();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CustomersNotifier>().resetPage();
      loadData();
    });
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CustomersNotifier>().resetPage();
      log(query);
      context
          .read<CustomersNotifier>()
          .getCustomers(search: query, price: widget.price);
    });
  }

  loadData() {
    context
        .read<CustomersNotifier>()
        .getCustomers(search: searchController.text, price: widget.price);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Consumer<CustomersNotifier>(
          builder: (context, value, child) {
            return Column(children: [
              Expanded(
                child: GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
                    },
                    child: _buildList(
                        customers: value.customers!,
                        isLoading: value.isLoading,
                        page: value.customerPage)),
              ),
              if (value.customerPage != 1 && value.isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: colorPrimary,
                  ),
                ),
              const SizedBox(height: 12),
            ]);
          },
        ),
      ),
    );
  }

  _buildAppBar() => AppBar(
        title: SizedBox(
          height: 36,
          child: RevoPosTextField(
            controller: searchController,
            hintText: "Search customer",
            formsearch: true,
            maxLines: 1,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).primaryColor,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                searchController.clear();
                context.read<CustomersNotifier>().resetPage();
                loadData();
              },
              icon: Icon(
                Icons.close_rounded,
                size: 16,
                color: colorDisabled,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
      );

  Widget _buildList(
      {List<Customer?>? customers,
      required bool isLoading,
      required int page}) {
    //customers ??= List.generate(8, (index) => null);

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
    return ListView.builder(
      itemCount: customers!.length,
      shrinkWrap: true,
      controller: _scrollController,
      itemBuilder: (_, index) {
        return ItemSearchCustomer(
          onTap: () {
            Navigator.pop(context, customers[index]);
          },
          customer: customers[index],
        );
      },
    );
  }
}
