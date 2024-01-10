import 'dart:convert';
import 'dart:developer';

import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/layers/data/models/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<List<StoreModel>> getStores();
  Future<StoreModel> addStore(
      {String? storeName,
      String? url,
      String? consumerKey,
      String? consumerSecret,
      bool? isLogin,
      String? cookie});
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  @override
  Future<List<StoreModel>> getStores() async {
    List list = [];
    if (AppConfig.data!.containsKey('list_stores')) {
      String? stores = AppConfig.data!.getString('list_stores');
      list = json.decode(stores!);
    }
    return list.map((store) => StoreModel.fromJson(store)).toList();
  }

  @override
  Future<StoreModel> addStore(
      {String? storeName,
      String? url,
      String? consumerKey,
      String? consumerSecret,
      bool? isLogin,
      String? cookie}) async {
    try {
      List<StoreModel> stores = [];
      StoreModel? store;
      store = StoreModel(
          storeName: storeName,
          url: url,
          consumerKey: consumerKey,
          consumerSecret: consumerSecret,
          isLogin: isLogin,
          cookie: cookie);
      if (AppConfig.data!.containsKey('list_stores') &&
          AppConfig.data!.getString('list_stores') != null) {
        String? decodeStores = AppConfig.data!.getString('list_stores');
        stores = (json.decode(decodeStores!) as List<dynamic>)
            .map<StoreModel>((item) => StoreModel.fromJson(item))
            .toList();
        stores.add(store);
      } else {
        stores.add(store);
      }
      String encodeStores = json.encode(
        stores.map((v) => v.toJson()).toList(),
      );
      await AppConfig.data!.setString('list_stores', encodeStores);
      return store;
    } catch (e) {
      log('Error');
      throw UnimplementedError();
    }
  }
}
