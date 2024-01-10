import 'package:flutter/cupertino.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';
import 'package:revo_pos/layers/domain/usecases/product/delete_product_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/get_products_usecase.dart';

class ProductsNotifier with ChangeNotifier {
  final GetProductsUsecase _getProductsUsecase;
  final DeleteProductUsecase _deleteProductUsecase;

  ProductsNotifier({
    required GetProductsUsecase getProductsUsecase,
    required DeleteProductUsecase deleteProductUsecase,
  })  : _getProductsUsecase = getProductsUsecase,
        _deleteProductUsecase = deleteProductUsecase;

  List<Product>? products = [];
  List<Product>? tempList;
  bool isLoadingProducts = false;

  Status? statusDelete;
  bool isLoadingStatus = false;
  int page = 1;

  Future<void> getProducts({String? search}) async {
    isLoadingProducts = true;
    notifyListeners();

    // printLog(selectedCategoryId.toString(), name:'Sel Cat');
    final result = await _getProductsUsecase(
        GetProductsParams(search: search, categoryId: null, page: page));

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

  Future<Status?> deleteProduct(
      {required String id, required String cookie}) async {
    isLoadingStatus = true;
    notifyListeners();

    final result = await _deleteProductUsecase(
        DeleteProductParams(id: id, cookie: cookie));

    result.fold((l) {}, (r) {
      statusDelete = r;
    });

    isLoadingStatus = false;
    notifyListeners();

    return statusDelete;
  }

  reset() {
    page = 1;
    products = [];
    tempList = [];

    notifyListeners();
  }
}
