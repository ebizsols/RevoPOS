import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';
import 'package:revo_pos/layers/presentation/products/notifier/form_product_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_text_field.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

class BottomSheetCategory extends StatefulWidget {
  final List<Category> selected;
  final List<Category?>? categories;
  final bool isLoading;

  const BottomSheetCategory(
      {Key? key,
      required this.selected,
      this.categories,
      required this.isLoading})
      : super(key: key);

  @override
  _BottomSheetCategoryState createState() => _BottomSheetCategoryState();
}

class _BottomSheetCategoryState extends State<BottomSheetCategory> {
  TextEditingController searchController = TextEditingController();
  bool clear = false;

  getProduct() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context
          .read<FormProductNotifier>()
          .getCategories(search: searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    var categories = widget.categories ?? List.generate(6, (index) => null);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          RevoPosTextField(
            controller: searchController,
            maxLines: 1,
            hintText: "Search Category",
            suffixIcon: clear || searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        clear = false;
                      });
                      getProduct();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: colorPrimary,
                    ),
                  )
                : null,
            onTap: () {
              setState(() {
                clear = true;
              });
            },
            onComplete: () {
              setState(() {
                clear = true;
              });
              getProduct();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onChanged: (val) {},
          ),
          Consumer<FormProductNotifier>(
            builder: (context, value, child) {
              return Expanded(
                child: ListView.separated(
                    itemCount: value.categories!.length,
                    itemBuilder: (_, index) {
                      if (value.categories?[index] == null ||
                          widget.isLoading) {
                        return Shimmer.fromColors(
                          baseColor: colorDisabled,
                          highlightColor: colorWhite,
                          child: Row(
                            children: [
                              Checkbox(
                                  value: false,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (value) {}),
                              Text(
                                "",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ],
                          ),
                        );
                      }

                      bool isSelected = value.selectedCategories
                          .where((e) {
                            return e.termId == value.categories![index].id ||
                                e.id == value.categories![index].id;
                          })
                          .toList()
                          .isNotEmpty;

                      return Padding(
                        padding: EdgeInsets.only(
                            left: (20 *
                                value.categories![index].level!.toDouble())),
                        child: Row(
                          children: [
                            Checkbox(
                                value: isSelected,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (v) {
                                  setState(() {
                                    if (v!) {
                                      context
                                          .read<FormProductNotifier>()
                                          .addSelectedCategories(
                                              value.categories![index]);
                                    } else {
                                      context
                                          .read<FormProductNotifier>()
                                          .removeSelectedCategories(
                                              value.categories![index].termId ??
                                                  value.categories![index].id!);
                                    }
                                  });
                                }),
                            Text(
                              value.categories![index].name ?? "",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, index) => const SizedBox(height: 8)),
              );
            },
            // child: Expanded(
            //   child: ListView.separated(
            //       itemCount: categories.length,
            //       itemBuilder: (_, index) {
            //         if (categories[index] == null || widget.isLoading) {
            //           return Shimmer.fromColors(
            //             baseColor: colorDisabled,
            //             highlightColor: colorWhite,
            //             child: Row(
            //               children: [
            //                 Checkbox(
            //                     value: false,
            //                     activeColor: Theme.of(context).primaryColor,
            //                     onChanged: (value) {}),
            //                 Text(
            //                   "",
            //                   style: Theme.of(context).textTheme.bodyText1,
            //                 ),
            //               ],
            //             ),
            //           );
            //         }

            //         bool isSelected = widget.selected
            //             .where((e) {
            //               return e.termId == categories[index]!.id ||
            //                   e.id == categories[index]!.id;
            //             })
            //             .toList()
            //             .isNotEmpty;

            //         return Padding(
            //           padding: EdgeInsets.only(
            //               left: (20 * categories[index]!.level!.toDouble())),
            //           child: Row(
            //             children: [
            //               Checkbox(
            //                   value: isSelected,
            //                   activeColor: Theme.of(context).primaryColor,
            //                   onChanged: (value) {
            //                     setState(() {
            //                       if (value!) {
            //                         context
            //                             .read<FormProductNotifier>()
            //                             .addSelectedCategories(
            //                                 categories[index]!);
            //                       } else {
            //                         context
            //                             .read<FormProductNotifier>()
            //                             .removeSelectedCategories(
            //                                 categories[index]!.termId ??
            //                                     categories[index]!.id!);
            //                       }
            //                     });
            //                   }),
            //               Text(
            //                 categories[index]!.name ?? "",
            //                 style: Theme.of(context).textTheme.bodyText1,
            //               ),
            //             ],
            //           ),
            //         );
            //       },
            //       separatorBuilder: (_, index) => const SizedBox(height: 8)),
            // ),
          ),
        ],
      ),
    );
  }
}
