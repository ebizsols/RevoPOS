import 'dart:convert';

import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';

abstract class CartLocalDataSource {
  Future<List<ProductModel>> getCart();
  Future<bool> addToCart({ProductModel? product});
  Future<bool> increaseQtyProduct({Product? product});
  Future<bool> decreaseQtyProduct({Product? product});
  Future<bool> removeCartProduct({Product? product});
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  @override
  Future<List<ProductModel>> getCart() async {
    List<ProductModel>? carts = [];

    if (AppConfig.data!.containsKey('user_cart')) {
      List products = json.decode(AppConfig.data!.getString('user_cart')!);
      carts =
          products.map((product) => ProductModel.fromJson(product)).toList();
    }

    return carts;
  }

  @override
  Future<bool> addToCart({ProductModel? product}) async {
    if (!AppConfig.data!.containsKey('user_cart')) {
      List<ProductModel> listCart = [];

      listCart.add(product!);
      await AppConfig.data!.setString('user_cart', json.encode(listCart));

      return true;
    } else {
      List products =
          await json.decode(AppConfig.data!.getString('user_cart').toString());
      List<ProductModel> listCart =
          products.map((product) => ProductModel.fromJson(product)).toList();
      int index = products.indexWhere((prod) =>
          prod["id"] == product!.id &&
          prod['variation_id'] == product.selectedVariationId &&
          prod['variation_name'] == product.selectedVariationName);

      if (index != -1) {
        product!.quantity = listCart[index].quantity! + product.quantity!;
        listCart[index] = product;

        await AppConfig.data!.setString('user_cart', json.encode(listCart));

        return true;
      } else {
        listCart.add(product!);
        await AppConfig.data!.setString('user_cart', json.encode(listCart));

        return true;
      }
    }
  }

  @override
  Future<bool> increaseQtyProduct({Product? product}) async {
    List products =
        json.decode(AppConfig.data!.getString('user_cart').toString());
    List<ProductModel> listCart =
        products.map((product) => ProductModel.fromJson(product)).toList();

    int index = products.indexWhere((prod) =>
        prod["id"] == product!.id &&
        prod['variation_id'] == product.selectedVariationId &&
        prod['variation_name'] == product.selectedVariationName);

    if (index != -1) {
      ProductModel dataCart = listCart
          .where((prod) =>
              prod.id == product!.id &&
              prod.selectedVariationId == product.selectedVariationId &&
              prod.selectedVariationName == product.selectedVariationName)
          .toList()[0];
      dataCart.quantity = listCart[index].quantity! + 1;
      listCart[index] = dataCart;
      await AppConfig.data!.setString('user_cart', json.encode(listCart));
    }
    return true;
  }

  @override
  Future<bool> decreaseQtyProduct({Product? product}) async {
    List products =
        json.decode(AppConfig.data!.getString('user_cart').toString());
    List<ProductModel> listCart =
        products.map((product) => ProductModel.fromJson(product)).toList();

    int index = products.indexWhere((prod) =>
        prod["id"] == product!.id &&
        prod['variation_id'] == product.selectedVariationId &&
        prod['variation_name'] == product.selectedVariationName);

    if (index != -1) {
      ProductModel dataCart = listCart
          .where((prod) =>
              prod.id == product!.id &&
              prod.selectedVariationId == product.selectedVariationId &&
              prod.selectedVariationName == product.selectedVariationName)
          .toList()[0];
      if (dataCart.quantity! > 1) {
        dataCart.quantity = listCart[index].quantity! - 1;
        listCart[index] = dataCart;
        await AppConfig.data!.setString('user_cart', json.encode(listCart));
      }
    }
    return true;
  }

  @override
  Future<bool> removeCartProduct({Product? product}) async {
    List products =
        json.decode(AppConfig.data!.getString('user_cart').toString());
    List<ProductModel> listCart =
        products.map((product) => ProductModel.fromJson(product)).toList();
    int index = products.indexWhere((prod) =>
        prod["id"] == product!.id &&
        prod['variation_id'] == product.selectedVariationId &&
        prod['variation_name'] == product.selectedVariationName);

    if (index != -1) {
      listCart.remove(listCart[index]);

      await AppConfig.data!.setString('user_cart', json.encode(listCart));
    }

    return true;
  }
}
