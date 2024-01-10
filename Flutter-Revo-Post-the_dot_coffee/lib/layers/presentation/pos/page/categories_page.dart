import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/categories_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          context.read<CategoriesNotifier>().tempList!.length % 10 == 0) {
        context.read<CategoriesNotifier>().getCategories();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CategoriesNotifier>().reset();
      context.read<CategoriesNotifier>().getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.select((CategoriesNotifier n) => n.categories);
    final isLoadingCategories =
        context.select((CategoriesNotifier n) => n.isLoadingCategories);
    final tempList = context.select((CategoriesNotifier n) => n.tempList);
    final page = context.select((CategoriesNotifier n) => n.page);

    final isExpandedCategories =
        context.select((CategoriesNotifier n) => n.isExpandedCategories);

    return Scaffold(
        appBar: _buildAppBar(),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildList(
                      categories: categories,
                      isExpandedCategories: isExpandedCategories,
                      isLoading: isLoadingCategories,
                      page: page),
                  if (page != 1 &&
                      tempList!.length % 10 == 0 &&
                      isLoadingCategories)
                    Center(
                      child: CircularProgressIndicator(
                        color: colorPrimary,
                      ),
                    ),
                  const SizedBox(height: 72),
                ],
              ),
            )));
  }

  _buildAppBar() => AppBar(
        title: const Text("All Categories"),
      );

  _buildList(
      {required List<Category?>? categories,
      required List<bool>? isExpandedCategories,
      required bool isLoading,
      int? page}) {
    categories ??= List.generate(6, (index) => null);

    if (isLoading && page == 1) {
      return ListView.separated(
        itemCount: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) {
          return Shimmer.fromColors(
            baseColor: colorDisabled,
            highlightColor: colorWhite,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          "assets/images/placeholder_user.png",
                          fit: BoxFit.cover,
                          width: RevoPosMediaQuery.getWidth(context) * 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "",
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: colorBlack),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, index) => Container(
          height: 1,
          color: colorDisabled,
        ),
      );
    }

    return ListView.separated(
      itemCount: categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                context.read<PosNotifier>().setIsSearch(true);
                context
                    .read<PosNotifier>()
                    .setSelectedCategory(index, categories![index]!.id!);
              },
              child: Row(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      child: categories![index]?.image?.src != null
                          ? Image.network(
                              categories[index]!.image!.src!,
                              fit: BoxFit.cover,
                              width: RevoPosMediaQuery.getWidth(context) * 0.2,
                            )
                          : Image.asset(
                              "assets/images/placeholder_user.png",
                              fit: BoxFit.cover,
                              width: RevoPosMediaQuery.getWidth(context) * 0.2,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      categories[index]!.name ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: colorBlack),
                    ),
                  ),
                  const Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, index) => Container(
        height: 1,
        color: colorDisabled,
      ),
    );
  }
}
