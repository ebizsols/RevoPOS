import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/login_model.dart';
import 'package:revo_pos/layers/data/models/store_model.dart';
import 'package:revo_pos/layers/domain/entities/login.dart';
import 'package:revo_pos/layers/domain/usecases/store/add_store_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/store/get_stores_usecase.dart';
import 'package:revo_pos/services/base_api.dart';

class StoreNotifier with ChangeNotifier {
  final GetStoresUsecase _getStoresUsecase;
  final AddStoreUsecase _addStoresUsecase;

  StoreNotifier(
      {required GetStoresUsecase getStoresUsecase,
      required AddStoreUsecase addStoreUsecase})
      : _getStoresUsecase = getStoresUsecase,
        _addStoresUsecase = addStoreUsecase;

  List<StoreModel>? stores;
  StoreModel? store;
  StoreModel? selectedStore;

  bool isDemo = false;

  Future<void> getStores() async {
    notifyListeners();

    final result = await _getStoresUsecase(NoParams());

    result.fold((l) {}, (r) {
      stores = r;
    });

    notifyListeners();
  }

  Future<void> addStore(
      {required String storeName,
      required String url,
      required String consumerKey,
      required String consumerSecret,
      required bool isLogin,
      required String cookie}) async {
    notifyListeners();

    final result = await _addStoresUsecase(AddStoreParams(
        storeName: storeName,
        url: url,
        consumerKey: consumerKey,
        consumerSecret: consumerSecret,
        isLogin: isLogin,
        cookie: cookie));

    result.fold(
      (e) {
      },
      (r) {
        store = r;
      },
    );

    notifyListeners();
  }

  onSelectedStore(StoreModel? _store) async {
    selectedStore = _store;
    await AppConfig.data!.remove('user_cart');
    await AppConfig.data!.setString('url', selectedStore!.url.toString());
    await AppConfig.data!.setString('ck', selectedStore!.consumerKey.toString());
    await AppConfig.data!.setString('cs', selectedStore!.consumerSecret.toString());
    await AppConfig.data!.setString('selected_store', json.encode(selectedStore));

    printLog(selectedStore!.consumerSecret!);
    notifyListeners();
  }

  updateStoreData(Login user) async {
    List _stores = [];
    String? decodeStores = AppConfig.data!.getString('list_stores');
    _stores = (json.decode(decodeStores!) as List<dynamic>)
        .map<StoreModel>((item) => StoreModel.fromJson(item))
        .toList();
    for (StoreModel element in _stores) {
      if (element.consumerSecret == selectedStore!.consumerSecret){
        element.cookie = user.cookie;
        element.isLogin = true;
        element.user = user as LoginModel?;
        printLog(element.cookie!);
      }
    }
    String encodeStores = json.encode(
      _stores.map((v) => v.toJson()).toList(),
    );
    printLog(_stores.toString(), name: 'List Store');
    await AppConfig.data!.setString('list_stores', encodeStores);
  }

  Future<void> logout() async {
    await AppConfig.data!.setBool('isLogin', false);
    await AppConfig.data!.setBool('isRememberMe', false);

    await AppConfig.data!.remove('user_cart');
    await AppConfig.data!.remove('url');
    await AppConfig.data!.remove('ck');
    await AppConfig.data!.remove('cs');

    await AppConfig.data!.remove('cookie');
    await AppConfig.data!.remove('order_notes');
    isDemo = false;
    notifyListeners();
  }

  changeDemoStatus(){
    isDemo = true;
    notifyListeners();
  }

  Future<bool> checkIsLogin() async {
    bool _valid = false;

    if (AppConfig.data?.containsKey('isLogin') != null &&
        AppConfig.data?.getBool('isLogin') == true) {
      if (AppConfig.data?.getBool('isRememberMe') != null &&
          AppConfig.data?.getBool('isRememberMe') == true) {
        var url = AppConfig.data!.getString('url');
        var ck =AppConfig.data!.getString('ck');
        var cs = AppConfig.data!.getString('cs');
        var _selectedStore = AppConfig.data!.getString('selected_store');
        selectedStore = StoreModel.fromJson(json.decode(_selectedStore!));
        printLog("$url $ck $cs");
        baseAPI = BaseWooAPI(url,ck,cs);
        _valid = true;
      }
    }
    notifyListeners();
    return _valid;
  }
}
