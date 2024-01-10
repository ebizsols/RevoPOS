import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/data/models/product_attribute_model.dart';
import 'package:revo_pos/layers/data/models/variation_data_model.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';
import 'package:revo_pos/layers/domain/usecases/category/get_categories_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/insert_product_usecase.dart';

class FormProductNotifier with ChangeNotifier {
  final GetCategoriesUsecase _getCategoriesUsecase;
  final InsertProductUsecase _insertProductUsecase;

  FormProductNotifier(
      {required GetCategoriesUsecase getCategoriesUsecase,
      required InsertProductUsecase insertProductUsecase})
      : _getCategoriesUsecase = getCategoriesUsecase,
        _insertProductUsecase = insertProductUsecase;

  List<String> listStockStatus = ["In Stock", "Out of stock"];
  int? selectedStockStatus = 0;

  List<Category>? categories;
  List<Category> selectedCategories = [];
  bool isLoadingCategories = true;

  Status? statusInsert;
  bool isLoadingInsert = false;

  String? productData = "Simple";
  XFile? imageMain;
  List<XFile> listGalleryImages = [];
  List<String> listBase64 = [];

  Future<void> getCategories({String? search}) async {
    isLoadingCategories = true;
    notifyListeners();

    final result = await _getCategoriesUsecase(GetCategoriesParams(
      page: 1,
      limit: 100,
      search: search,
    ));

    result.fold((l) {}, (r) {
      categories = r;
    });

    isLoadingCategories = false;
    notifyListeners();
  }

  getBase64() {
    if (imageMain != null) {
      List<int> bytes = File(imageMain!.path).readAsBytesSync();
      String base64 = base64Encode(bytes);
      listBase64.add(base64);
      for (int i = 0; i < listGalleryImages.length; i++) {
        List<int> bytes = File(listGalleryImages[i].path).readAsBytesSync();
        String base64 = base64Encode(bytes);
        listBase64.add(base64);
      }
      notifyListeners();
    }
  }

  Future<Status?> insertProduct(
      {required String cookie,
      String? id,
      required String name,
      required String description,
      int? regularPrice,
      int? salePrice,
      double? weight,
      double? width,
      double? height,
      double? length,
      String? sku,
      required List<int> idCategories,
      required String type,
      String? stockStatus,
      bool? manageStock,
      int? stock,
      List<VariationData>? variationData,
      List<ProductAtributeModel>? productAttribute,
      required String titleImage,
      String? image}) async {
    isLoadingInsert = true;
    notifyListeners();

    final result = await _insertProductUsecase(InsertProductParams(
        cookie: cookie,
        id: id,
        name: name,
        description: description,
        regularPrice: regularPrice,
        salePrice: salePrice,
        weight: weight,
        width: width,
        height: height,
        length: length,
        sku: sku,
        idCategories: idCategories,
        type: type,
        stockStatus: stockStatus,
        manageStock: manageStock,
        stock: stock,
        variationData: variationData,
        productAttribute: productAttribute,
        titleImage: titleImage,
        image: image ?? "",
        base64: listBase64));
    printLog("result insert : ${result}");

    result.fold((l) {}, (r) {
      statusInsert = r;
    });

    isLoadingInsert = false;
    notifyListeners();

    return statusInsert;
  }

  setSelectedCategories(List<Category> values) {
    selectedCategories = values;
    notifyListeners();
  }

  addSelectedCategories(Category value) {
    selectedCategories.add(value);
    notifyListeners();
  }

  removeSelectedCategories(int id) {
    selectedCategories
        .removeWhere((element) => element.id == id || element.termId == id);
    notifyListeners();
  }

  setImageMain(XFile value) {
    imageMain = value;
    notifyListeners();
  }

  addImageGallery(XFile value) {
    listGalleryImages.insert(0, value);
    notifyListeners();
  }

  removeImageGallery(int value) {
    List<XFile> list = List.from(listGalleryImages);
    list.removeAt(value);
    listGalleryImages = list;
    notifyListeners();
  }

  setProductData(String value) {
    productData = value;
    notifyListeners();
  }

  setSelectedStockStatus(int value) {
    selectedStockStatus = value;
    notifyListeners();
  }

  reset() {
    statusInsert = null;
    isLoadingInsert = false;

    categories = null;
    selectedCategories = [];
    isLoadingCategories = true;

    productData = null;
    imageMain = null;
    listGalleryImages = [];
    listBase64 = [];
    selectedStockStatus = 0;

    notifyListeners();
  }
}
