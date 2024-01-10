import 'package:flutter/cupertino.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/usecases/auth/check_validate_cookie_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/category/get_categories_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/get_products_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/scan_product_usecase.dart';

class PosNotifier with ChangeNotifier {
  final GetCategoriesUsecase _getCategoriesUsecase;
  final GetProductsUsecase _getProductsUsecase;
  final ScanProductUsecase _scanProductUsecase;
  final CheckValidateCookieUsecase _checkValidateCookieUsecase;

  PosNotifier(
      {required GetCategoriesUsecase getCategoriesUsecase,
      required GetProductsUsecase getProductsUsecase,
      required ScanProductUsecase scanProductUsecase,
      required CheckValidateCookieUsecase checkValidateCookieUsecase})
      : _getCategoriesUsecase = getCategoriesUsecase,
        _getProductsUsecase = getProductsUsecase,
        _scanProductUsecase = scanProductUsecase,
        _checkValidateCookieUsecase = checkValidateCookieUsecase;

  List<Category>? categories;
  bool isLoadingCategories = false;

  List<Product>? products = [];
  List<Product>? tempList;

  List<Product>? productScan;

  bool isLoadingProducts = false;

  bool isSearch = false;
  bool isLoading = false;

  int selectedCategory = 0;
  int selectedCategoryId = 0;

  int? selectedVariant;
  int quantity = 0;

  String? barcodeScanRes;

  List<String> methods = ["Cash", "Payment Gateway A", "Payment Gateway B"];

  int page = 1;

  Future<void> getCategories() async {
    isLoadingCategories = true;
    notifyListeners();

    final result = await _getCategoriesUsecase(
        const GetCategoriesParams(page: 1, limit: 10));

    result.fold((l) {}, (r) {
      categories = r;
    });

    isLoadingCategories = false;
    notifyListeners();
  }

  Future<void> getProducts({String? search}) async {
    isLoadingProducts = true;
    notifyListeners();

    // printLog(selectedCategoryId.toString(), name:'Sel Cat');
    final result = await _getProductsUsecase(GetProductsParams(
        search: search, categoryId: selectedCategoryId, page: page));
    printLog("Search : $search");
    result.fold((l) {
      products = [];
    }, (r) {
      tempList = [];
      tempList!.addAll(r);
      List<Product> list = List.from(products!);
      list.addAll(tempList!);
      products = list;
      if (tempList!.length % 10 == 0) {
        page++;
      }
    });
    isLoadingProducts = false;

    notifyListeners();
  }

  Future<void> scanBarcode(
      {String? sku, required Function(String, bool, bool) onSubmit}) async {
    isLoadingProducts = true;
    notifyListeners();

    final result = await _scanProductUsecase(ScanProductParams(sku: sku));

    result.fold((l) {
      productScan = [];
      isLoadingProducts = false;
      onSubmit('Failed when trying fetch data from server', isLoadingProducts,
          false);
    }, (r) {
      productScan = r;
      isLoadingProducts = false;
      if (productScan!.isEmpty) {
        onSubmit('Product not found', isLoadingProducts, false);
      } else {
        onSubmit('Success', isLoadingProducts, true);
      }
    });
    notifyListeners();
  }

  Future<Map<String, dynamic>> checkValidateCookie() async {
    notifyListeners();

    final result = await _checkValidateCookieUsecase(NoParams());
    var res;
    result.fold(
      (e) {
        printLog('Failed');
        isLoading = false;
      },
      (r) {
        printLog('Success - $r');
        res = r;
        isLoading = false;
      },
    );

    notifyListeners();
    return res;
  }

  setIsSearch(bool value) {
    isSearch = value;
    printLog("isSearch ${isSearch}");
    notifyListeners();
  }

  setSelectedCategory(int value, int categoriesId) {
    selectedCategory = value;
    selectedCategoryId = categoriesId;
    resetPage();
    getProducts();
    notifyListeners();
  }

  setSelectedVariant(int value) {
    selectedVariant = value;
    notifyListeners();
  }

  setQuantity(int value) {
    quantity = value;
    notifyListeners();
  }

  resetPage() {
    page = 1;
    products = [];
    tempList = [];
    notifyListeners();
  }

  reset() {
    categories = null;
    page = 1;
    products = [];
    tempList = [];
    isLoadingCategories = false;
    selectedCategory = 0;
    selectedCategoryId = 0;
    selectedVariant = null;
    notifyListeners();
  }
}
