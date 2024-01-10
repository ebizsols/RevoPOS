import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/data/models/variation_data_model.dart';
import 'package:revo_pos/layers/data/sources/remote/product_remote_data_source.dart';
import 'package:revo_pos/layers/domain/usecases/product/get_attribute_usecase.dart';

class AttributeNotifier with ChangeNotifier {
  final GetAttributeUsecase _getAttributeUsecase;

  AttributeNotifier({
    required GetAttributeUsecase getAttributeUsecase,
  }) : _getAttributeUsecase = getAttributeUsecase;

  List<Attribute> listAttribute = [];
  List<VariationData> listVariant = [];
  List<ProductAtributeModel>? listProductAttribute = [];
  bool isLoadingAttribute = true;

  Future<void> fetchAttribute({String? cookie}) async {
    isLoadingAttribute = true;
    //notifyListeners();
    listAttribute.clear();
    final result =
        await _getAttributeUsecase(GetAttributeParams(cookie: cookie));

    result.fold((l) {
      listAttribute = [];
    }, (r) {
      listAttribute.addAll(r);
      for (int i = 0; i < listAttribute.length; i++) {
        Term term = Term(
            termID: "0",
            name: "All",
            slug: "All",
            termGroup: "0",
            termTaxonomyID: "0",
            taxonomy: listAttribute[i].term![0].taxonomy,
            description: "",
            parent: "0",
            count: 1,
            filter: "raw",
            selected: true);
        listAttribute[i].term!.add(term);
        listAttribute[i].term!.sort(
              (a, b) => a.termID!.compareTo(b.termID!),
            );
      }
      printLog("selected : ${listAttribute[0].selected}");
    });
    isLoadingAttribute = false;
    notifyListeners();
  }

  deleteVariant(int? index) {
    listVariant[index!].deleteProductVariant = "yes";
    notifyListeners();
  }

  updateVariant(
      {String? regPrice,
      String? salePrice = "",
      String? weight = "",
      String? width = "",
      String? length = "",
      String? height = "",
      String? stockStatus,
      String? manageStock,
      String? stock = "",
      int? index,
      String? id,
      List<VariationAttributesModel>? listVariantAttr}) {
    VariationData varModel = VariationData(
        varRegularPrice: regPrice,
        varSalePrice: salePrice,
        weight: weight,
        width: width,
        variableProductId: id,
        length: length,
        height: height,
        varStockStatus: stockStatus,
        varManageStock: manageStock,
        varStock: stock,
        listVariationAttr: listVariantAttr);
    listVariant[index!] = varModel;
    notifyListeners();
  }

  submitVariant(
      {String? regPrice,
      String? salePrice = "",
      String? weight = "",
      String? width = "",
      String? length = "",
      String? height = "",
      String? stockStatus,
      String? manageStock,
      String? stock = "",
      String? variableSku = "",
      List<VariationAttributesModel>? listVariantAttr}) {
    VariationData varModel = VariationData(
        varRegularPrice: regPrice,
        varSalePrice: salePrice,
        weight: weight,
        width: width,
        length: length,
        height: height,
        varStockStatus: stockStatus,
        varManageStock: manageStock,
        varStock: stock,
        variableSku: variableSku,
        listVariationAttr: listVariantAttr);
    listVariant.add(varModel);
    notifyListeners();
  }

  getProdAttribute() {
    String? taxonomyName;
    List<String> options = [];
    ProductAtributeModel prodAttribute;
    listProductAttribute!.clear();
    options.clear();
    for (int i = 0; i < listAttribute.length; i++) {
      if (listAttribute[i].selected) {
        for (int j = 0; j < listAttribute[i].term!.length; j++) {
          String name = listAttribute[i].term![j].name!.toLowerCase();
          taxonomyName = listAttribute[i].term![j].taxonomy;

          if (name != "All" && name != "all") {
            if (listAttribute[i].term![j].selected) {
              options.add(name);
              printLog("${j} - ${name}");
            }
          }
        }

        prodAttribute = new ProductAtributeModel(
            taxonomyName: taxonomyName,
            variation: true,
            visible: true,
            options: options);
        listProductAttribute!.add(prodAttribute);
        notifyListeners();
        options = [];
      }
    }

    notifyListeners();
  }

  setListAttribute(List<Attribute> value) {
    if (value.length > 0) {
      printLog("Condition 1");
      for (int i = 0; i < listAttribute.length; i++) {
        for (int j = 0; j < value.length; j++) {
          if (listAttribute[i].id == value[j].id) {
            printLog("Condition 2");
            listAttribute[i].selected = true;
            value[j].selected = true;
            for (int k = 0; k < listAttribute[i].term!.length; k++) {
              for (int l = 0; l < value[j].term!.length; l++) {
                if (value[j].term![l].termID ==
                    listAttribute[i].term![k].termID) {
                  printLog("masuk list attribute term");
                  listAttribute[i].term![k].selected = true;
                }
              }
            }
          }
        }
      }
    }
    for (int i = 0; i < listAttribute.length; i++) {
      if (listAttribute[i].selected) {
        for (int j = 0; j < listAttribute[i].term!.length; j++) {
          if (listAttribute[i].term![j].selected) {
            listAttribute[i].selectedTerm = listAttribute[i].term!.first;
          }
        }
      }
    }
    notifyListeners();
  }

  setListVariant(List<VariationData> value) {
    listVariant = value;
    notifyListeners();
  }

  reset() {
    listAttribute.clear();
    isLoadingAttribute = true;
    listProductAttribute!.clear();
    listVariant.clear();
    notifyListeners();
  }
}
