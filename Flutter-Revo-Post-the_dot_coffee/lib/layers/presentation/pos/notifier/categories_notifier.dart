import 'package:flutter/cupertino.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';
import 'package:revo_pos/layers/domain/usecases/category/get_categories_usecase.dart';

class CategoriesNotifier with ChangeNotifier {
  final GetCategoriesUsecase _getCategoriesUsecase;

  CategoriesNotifier({
    required GetCategoriesUsecase getCategoriesUsecase,
  }) : _getCategoriesUsecase = getCategoriesUsecase;

  List<Category>? categories = [];
  List<Category>? tempList;

  bool isLoadingCategories = false;

  List<bool>? isExpandedCategories;

  int page = 1;

  Future<void> getCategories() async {
    isLoadingCategories = true;
    notifyListeners();

    final result = await _getCategoriesUsecase(GetCategoriesParams(
      page: page,
      limit: 10,
    ));

    result.fold((l) {
      categories = [];
      isLoadingCategories = false;
    }, (r) {
      tempList = [];
      tempList!.addAll(r);
      List<Category> list = List.from(categories!);
      list.addAll(tempList!);
      categories = list;
      if (tempList!.length % 10 == 0) {
        page++;
      }
      isLoadingCategories = false;
      notifyListeners();
    });
  }

  setExpandCategory({required int index, required bool isExpanded}) {
    if (isExpandedCategories != null) {
      List<bool> listIsExpanded = List.from(isExpandedCategories!);
      listIsExpanded[index] = isExpanded;
      isExpandedCategories = listIsExpanded;
      notifyListeners();
    }
  }

  reset() {
    page = 1;
    categories = [];
    tempList = [];
    notifyListeners();
  }
}
