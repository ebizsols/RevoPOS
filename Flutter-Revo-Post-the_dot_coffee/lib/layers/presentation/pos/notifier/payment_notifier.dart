import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/core/utils/currency_converter.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/check_price_model.dart';
import 'package:revo_pos/layers/data/models/checkout_model.dart';
import 'package:revo_pos/layers/data/models/coupon_model.dart';
import 'package:revo_pos/layers/data/models/place_order_model.dart' as place;
// import 'package:revo_pos/layers/data/models/order_model.dart';
import 'package:revo_pos/layers/data/models/product_model.dart';
import 'package:revo_pos/layers/data/models/shipping_method_model.dart';
import 'package:revo_pos/layers/data/models/variation_model.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/domain/usecases/checkout/add_to_cart_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/checkout/decrease_qty_product_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/checkout/get_cart_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/checkout/increase_qty_product_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/checkout/remove_cart_product_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/coupon/apply_coupon_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/coupon/get_coupon_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/check_price_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/create_order_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/get_shipping_method_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/place_order_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/chek_variation_usecase.dart';

class PaymentNotifier with ChangeNotifier {
  final AddToCartUsecase _addToCartUsecase;
  final GetCartUsecase _getCartUsecase;
  final IncreaseQtyProductUsecase _increaseQtyUsecase;
  final DecreaseQtyProductUsecase _decreaseQtyUsecase;
  final RemoveCartProductUsecase _removeCartProductUsecase;
  final GetCouponUsecase _getCouponUsecase;
  final ApplyCouponUsecase _applyCouponUsecase;
  final CreateOrderUsecase _createOrderUsecase;
  final CheckVariationUsecase _checkVariationUsecase;
  final GetShippingMethodUsecase _getShippingMethodUsecase;
  final CheckPriceUsecase _checkPriceUsecase;
  final PlaceOrderUsecase _placeOrderUsecase;

  List<String> methods = ["Cash"];
  double total = 0;
  double changes = 0;
  String? customer;
  Customer? selectedCustomer;
  List<ProductModel> cartProduct = [];
  String? orderNotes = '';
  bool isLoading = false;
  bool loadCoupon = false;
  String? selectedShipping = "Select Shipping Method";

  bool? cartStatus;
  String? cartStatusText;

  String? couponStatus;
  CouponModel? selectedCoupon;
  double? discountAmount = 0;

  CheckoutModel? cart;
  place.PlaceOrderModel? cartV2;
  double? totalPrice = 0;
  double? grandTotal = 0;
  int totalItems = 0;

  //Printer
  OrderPrint? dataPrint;
  CheckoutPrint? printData;

  CouponsModel? resultCoupon;

  PaymentNotifier(
      {required AddToCartUsecase addToCartUsecase,
      required GetCartUsecase getCartUsecase,
      required IncreaseQtyProductUsecase increaseQtyUsecase,
      required DecreaseQtyProductUsecase decreaseQtyUsecase,
      required RemoveCartProductUsecase removeCartProductUsecase,
      required GetCouponUsecase getCouponUsecase,
      required ApplyCouponUsecase applyCouponUsecase,
      required CreateOrderUsecase createOrderUsecase,
      required CheckVariationUsecase checkVariationUsecase,
      required GetShippingMethodUsecase getShippingMethodUsecase,
      required CheckPriceUsecase checkPriceUsecase,
      required PlaceOrderUsecase placeOrderUsecase})
      : _addToCartUsecase = addToCartUsecase,
        _getCartUsecase = getCartUsecase,
        _increaseQtyUsecase = increaseQtyUsecase,
        _decreaseQtyUsecase = decreaseQtyUsecase,
        _removeCartProductUsecase = removeCartProductUsecase,
        _getCouponUsecase = getCouponUsecase,
        _applyCouponUsecase = applyCouponUsecase,
        _createOrderUsecase = createOrderUsecase,
        _checkVariationUsecase = checkVariationUsecase,
        _getShippingMethodUsecase = getShippingMethodUsecase,
        _checkPriceUsecase = checkPriceUsecase,
        _placeOrderUsecase = placeOrderUsecase;

  Future<void> getCart() async {
    notifyListeners();

    final result = await _getCartUsecase(NoParams());

    result.fold(
      (l) {},
      (r) {
        printLog("json : ${json.encode(r)}");
        cartProduct = r;
        setSubtotal();
      },
    );

    notifyListeners();
  }

  Future<Map<String, dynamic>?> checkVariation(
      {String? id, List<VariationModel>? variant}) async {
    var res;
    final result = await _checkVariationUsecase(
        CheckVariationParams(id: id!, variation: variant!));

    result.fold((l) {}, (r) {
      printLog(r.toString(), name: "Check Variation");
      res = r;
    });
    return res;
  }

  bool loading = false;

  Future<void> checkPrice({int? userId, List<LineItems>? lineItems}) async {
    List<CheckPriceModel> res = [];

    loading = true;
    notifyListeners();
    final result = await _checkPriceUsecase(
        CheckPriceParams(userId: userId!, lineItems: lineItems!));
    result.fold((l) {}, (r) {
      printLog(json.encode(r), name: "check price");
      for (int i = 0; i < r.length; i++) {
        for (int j = 0; j < cartProduct.length; j++) {
          if (r[i].productId == cartProduct[j].id) {
            cartProduct[j].priceUsed = r[i].price!.toDouble();
            notifyListeners();
          }
          if (r[i].variationId != null &&
              r[i].variationId == cartProduct[j].selectedVariationId) {
            cartProduct[j].priceUsed = r[i].price!.toDouble();
            notifyListeners();
          }
        }
      }
      setSubtotal();
      loading = false;
      notifyListeners();
    });
  }

  Future<void> addToCart(context,
      {required ProductModel product, required Function(String) onTap}) async {
    notifyListeners();

    final result = await _addToCartUsecase(AddToCartParams(product: product));

    result.fold((l) {}, (r) {
      cartStatus = r;
      if (cartStatus!) {
        cartStatusText = 'Product successfully added to cart';
      } else {
        cartStatusText = 'Product cannot added to cart';
      }
      onTap(cartStatusText!);
    });

    notifyListeners();
  }

  Future<void> increaseQty(
      {required ProductModel product, required Function(bool) onTap}) async {
    notifyListeners();

    final result =
        await _increaseQtyUsecase(IncreaseQtyParams(product: product));

    result.fold((l) {}, (r) {
      onTap(r);
      selectedCoupon = null;
      discountAmount = 0;
      notifyListeners();
    });

    notifyListeners();
  }

  Future<bool> cekQty(ProductModel product, int qty) async {
    if (product.variations != null) {
      for (var element in product.variations!) {
        if (element.variationId == product.selectedVariationId) {
          printLog("id product : ${element.maxQty}");

          if (element.maxQty >= qty + 1) {
            return true;
          }
        }
      }
    } else {
      if (product.stockStatus == "instock") {
        if (product.stockQuantity == null ||
            product.stockQuantity! >= qty + 1) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void> decreaseQty(
      {required ProductModel product, required Function(bool) onTap}) async {
    notifyListeners();

    final result =
        await _decreaseQtyUsecase(DecreaseQtyParams(product: product));

    result.fold((l) {}, (r) {
      onTap(r);
      selectedCoupon = null;
      discountAmount = 0;
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> removeCartProduct(context,
      {required ProductModel product, required Function(String) onTap}) async {
    notifyListeners();

    final result = await _removeCartProductUsecase(
        RemoveCartProductParams(product: product));

    result.fold((l) {}, (r) {
      String _status;
      if (r) {
        _status = 'Product successfully removed from cart.';
        selectedCoupon = null;
        discountAmount = 0;
        notifyListeners();
      } else {
        _status = 'Failed removing product from cart.';
      }
      onTap(_status);
    });

    notifyListeners();
  }

  bool loadShipping = false;
  List<ShippingMethodModel> shippingMethod = [];
  List<ShippingMethodModel> tempListShipping = [];
  ShippingMethodModel? selectedShippingMethod;
  Future<List<ShippingMethodModel>> getShippingMethod(
      {int? userId, List<LineItemsModel>? lineItems}) async {
    loadShipping = true;
    notifyListeners();
    final result = await _getShippingMethodUsecase(
        ShippingMethodParams(userId: userId!, lineItems: lineItems!));
    shippingMethod = [];
    result.fold((l) {
      shippingMethod = [];
      loadShipping = false;
    }, (r) {
      tempListShipping = [];
      tempListShipping.addAll(r);
      List<ShippingMethodModel> list = List.from(shippingMethod);
      list.addAll(tempListShipping);
      shippingMethod = list;
      loadShipping = false;
    });
    notifyListeners();
    return shippingMethod;
  }

  Future<bool> setShipping(ShippingMethodModel shipping) async {
    selectedShippingMethod = shipping;
    selectedShipping = shipping.methodTitle;
    notifyListeners();
    printLog(selectedShipping!, name: "Selected Shipping");
    return true;
  }

  Point? point;

  Future<void> applyPoint(Point pt) async {
    point = pt;
    notifyListeners();
  }

  Future<CouponsModel> applyCoupon(
      {int? userId,
      List<LineItemsModel>? lineItem,
      String? couponCode,
      required Function(String, bool, bool, bool) onSubmit}) async {
    loadCoupon = true;
    notifyListeners();
    final result = await _applyCouponUsecase(ApplyCouponParams(
        userId: userId!, lineItems: lineItem!, couponCode: couponCode!));

    result.fold((l) {
      loadCoupon = false;
    }, (r) {
      String _status;
      bool expired = false;
      bool available = false;
      resultCoupon = r;
      if (r.code == "error") {
        _status = r.message!;
        selectedCoupon = null;
        couponStatus = _status;
        available = false;
        discountAmount = 0;
      } else {
        _status =
            'DISCOUNT ${CurrencyConverter.currency(double.parse(r.message!))} APPLIED';
        available = true;
        selectedCoupon = CouponModel(code: couponCode);
        discountAmount = double.parse(r.message!);
        couponStatus = _status;
        notifyListeners();
        printLog(discountAmount.toString(), name: "Selected Coupon");
      }
      loadCoupon = false;
      onSubmit(_status, loadCoupon, expired, available);
      loadCoupon = false;
      notifyListeners();
      return resultCoupon!;
    });
    notifyListeners();
    return resultCoupon!;
  }

  Future<void> submitCoupon(context,
      {required String code,
      required Function(String, bool, bool, bool) onSubmit}) async {
    loadCoupon = true;

    notifyListeners();

    final result = await _getCouponUsecase(CouponParams(code: code));

    result.fold((l) {
      loadCoupon = false;
    }, (r) {
      String _status;
      bool expired = false;
      bool available = false;
      if (r.isEmpty) {
        _status = 'Coupon not found or not available';
        selectedCoupon = null;
        couponStatus = _status;
        available = false;
        discountAmount = 0;
      } else {
        final now = DateTime.now();
        final expirationDate = DateTime.parse(r.first.dateExpires!);
        final bool isExpired = expirationDate.isBefore(now);
        if (isExpired) {
          _status = 'COUPON ALREADY EXPIRED';
          selectedCoupon = null;
          discountAmount = 0;
          available = false;
        } else {
          if (r.first.discountType == 'fixed_cart') {
            _status =
                'DISCOUNT ${CurrencyConverter.currency(double.parse(r.first.amount!))} APPLIED';
            available = true;
          } else if (r.first.discountType == 'percent') {
            _status = 'DISCOUNT ${r.first.amount}% APPLIED';
            available = true;
          } else {
            _status =
                'Discount ${r.first.amount} currently could not be applied';
            available = false;
          }
          selectedCoupon = r.first;
        }
        expired = isExpired;
        couponStatus = _status;
      }
      loadCoupon = false;
      onSubmit(_status, loadCoupon, expired, available);
    });

    notifyListeners();
  }

  Future setSubtotal() async {
    double _totalPrice = 0, _grandTotal = 0;
    int _totalItems = 0;
    for (var element in cartProduct) {
      _totalPrice += (element.priceUsed! * element.quantity!);
      _totalItems += element.quantity!;
    }
    totalItems = _totalItems;
    totalPrice = _totalPrice;
    _grandTotal += totalPrice!;
    if (selectedCoupon != null) {
      _grandTotal -= discountAmount!;
    }
    if (point != null) {
      _grandTotal -= double.parse(point!.totalDiscount!);
    }
    if (selectedShippingMethod != null) {
      _grandTotal += selectedShippingMethod!.cost!;
    }
    grandTotal = _grandTotal;

    notifyListeners();
  }

  Future<bool> createOrder(String? paymentId, String? paymentTitle) async {
    bool valid = false;
    CheckoutModel order = CheckoutModel();

    BillingModel billing = BillingModel();
    ShippingModel shipping = ShippingModel();
    List<LineItemsModel> lineItems = [];
    List<CouponLinesModel> couponLines = [];
    List<ShippingLinesModel> shippingLines = [];

    if (totalItems != 0 &&
        selectedCustomer != null &&
        selectedShippingMethod != null) {
      if (selectedCustomer!.billing!.address1 == "" &&
          selectedCustomer!.billing!.address2 == "" &&
          selectedCustomer!.billing!.city == "" &&
          selectedCustomer!.billing!.company == "" &&
          selectedCustomer!.billing!.country == "" &&
          selectedCustomer!.billing!.email == "" &&
          selectedCustomer!.billing!.firstName == "" &&
          selectedCustomer!.billing!.lastName == "" &&
          selectedCustomer!.billing!.phone == "" &&
          selectedCustomer!.billing!.postcode == "" &&
          selectedCustomer!.billing!.state == "") {
        printLog("Masuk billing null");
        var _email = selectedCustomer!.email;
        var _firstName = selectedCustomer!.firstName;
        var _id = selectedCustomer!.id;
        var _lastName = selectedCustomer!.lastName;
        var _shiping = selectedCustomer!.shipping;
        var _username = selectedCustomer!.username;

        selectedCustomer = Customer(
          email: _email,
          firstName: _firstName,
          id: _id,
          lastName: _lastName,
          shipping: _shiping,
          username: _username,
          billing: Billing(
            address1: "POS",
            address2: "",
            city: "POS",
            company: "",
            country: "ID",
            email: _email,
            firstName: _firstName,
            lastName: _lastName,
            phone: "1234567890",
            postcode: "123456",
            state: "JI",
          ),
        );
      }

      if (selectedCustomer!.shipping!.address1 == "" &&
          selectedCustomer!.shipping!.address2 == "" &&
          selectedCustomer!.shipping!.city == "" &&
          selectedCustomer!.shipping!.company == "" &&
          selectedCustomer!.shipping!.country == "" &&
          selectedCustomer!.shipping!.firstName == "" &&
          selectedCustomer!.shipping!.lastName == "" &&
          selectedCustomer!.shipping!.postcode == "" &&
          selectedCustomer!.shipping!.state == "") {
        printLog("Masuk shipping null");
        var _email = selectedCustomer!.email;
        var _firstName = selectedCustomer!.firstName;
        var _id = selectedCustomer!.id;
        var _lastName = selectedCustomer!.lastName;
        var _username = selectedCustomer!.username;
        var _billing = selectedCustomer!.billing;

        selectedCustomer = Customer(
          email: _email,
          firstName: _firstName,
          id: _id,
          lastName: _lastName,
          username: _username,
          billing: _billing,
          shipping: Shipping(
            address1: "POS",
            address2: "",
            city: "POS",
            company: "",
            country: "ID",
            firstName: _firstName,
            lastName: _lastName,
            postcode: "123456",
            state: "JI",
          ),
        );
      }

      printLog(selectedCustomer.toString(), name: "selected customer");

      if (selectedCustomer != null) {
        billing = BillingModel(
          address1: selectedCustomer!.billing!.address1,
          address2: selectedCustomer!.billing!.address2,
          city: selectedCustomer!.billing!.city,
          company: selectedCustomer!.billing!.company,
          country: selectedCustomer!.billing!.country,
          firstName: selectedCustomer!.billing!.firstName,
          lastName: selectedCustomer!.billing!.lastName,
          postcode: selectedCustomer!.billing!.postcode,
          state: selectedCustomer!.billing!.state,
          phone: selectedCustomer!.billing!.phone,
          email: selectedCustomer!.billing!.email,
        );

        shipping = ShippingModel(
            address1: selectedCustomer!.shipping!.address1,
            address2: selectedCustomer!.shipping!.address2,
            city: selectedCustomer!.shipping!.city,
            company: selectedCustomer!.shipping!.company,
            country: selectedCustomer!.shipping!.country,
            firstName: selectedCustomer!.shipping!.firstName,
            lastName: selectedCustomer!.shipping!.lastName,
            postcode: selectedCustomer!.shipping!.postcode,
            state: selectedCustomer!.shipping!.state);
      }

      for (var element in cartProduct) {
        lineItems.add(LineItemsModel(
            quantity: element.quantity,
            productId: element.id,
            variationId: element.selectedVariationId ?? 0));
      }

      if (selectedCoupon != null) {
        couponLines.add(CouponLinesModel(code: selectedCoupon!.code));
      }
      if (selectedShippingMethod != null) {
        shippingLines.add(ShippingLinesModel(
            total: selectedShippingMethod!.cost.toString(),
            methodId: selectedShippingMethod!.methodId,
            methodTitle: selectedShippingMethod!.methodTitle));
      }

      if (selectedCustomer != null) {
        order = CheckoutModel(
            setPaid: paymentId == 'bacs' ? false : true,
            token: AppConfig.data!.getString('cookie'),
            paymentMethod: paymentId,
            paymentMethodTitle: paymentTitle,
            customerNote: orderNotes,
            totalPrice: totalPrice,
            totalDisc: discountAmount,
            grandTotal: grandTotal,
            lineItems: lineItems,
            customerId: selectedCustomer!.id,
            listProduct: cartProduct,
            couponLines: couponLines,
            shippingLines: shippingLines,
            shipping: shipping,
            billing: billing,
            status: paymentId == 'bacs' ? 'pending' : 'completed');
      }
      var jsonOrder = json.encode(order);
      printLog(jsonOrder);
      cart = order;
      valid = true;
    } else {
      valid = false;
    }
    notifyListeners();
    return valid;
  }

  Future<bool> createOrderV2(String? paymentId, String? paymentTitle) async {
    bool valid = false;
    place.PlaceOrderModel order = place.PlaceOrderModel();

    BillingModel billing = BillingModel();
    place.ShippingLinesModel shipping = place.ShippingLinesModel();
    List<place.LineItemsPlace> lineItems = [];
    String couponCode = "";
    place.PaymentMethodModel paymentMethod = place.PaymentMethodModel();

    if (totalItems != 0 &&
        selectedCustomer != null &&
        selectedShippingMethod != null) {
      //Line items
      for (var element in cartProduct) {
        lineItems.add(place.LineItemsPlace(
            productId: element.id,
            quantity: element.quantity,
            variationId: element.selectedVariationId));
      }
      //Billing address
      billing = BillingModel(
        address1: selectedCustomer!.billing!.address1,
        address2: selectedCustomer!.billing!.address2,
        city: selectedCustomer!.billing!.city,
        company: selectedCustomer!.billing!.company,
        country: selectedCustomer!.billing!.country,
        firstName: selectedCustomer!.billing!.firstName,
        lastName: selectedCustomer!.billing!.lastName,
        postcode: selectedCustomer!.billing!.postcode,
        state: selectedCustomer!.billing!.state,
        phone: selectedCustomer!.billing!.phone,
        email: selectedCustomer!.billing!.email,
      );
      printLog(json.encode(billing), name: "Billing");
      //Shipping Lines
      shipping = place.ShippingLinesModel(
          methodId: selectedShippingMethod!.methodId,
          methodTitle: selectedShippingMethod!.methodTitle,
          cost: selectedShippingMethod!.cost);

      //Payment method
      paymentMethod =
          place.PaymentMethodModel(id: paymentId, title: paymentTitle);
      List<Map<String, String>> listCode = [];
      Map<String, String> code = {};
      if (selectedCoupon != null) {
        code = {
          "code": selectedCoupon!.code!,
        };
        listCode.add(code);
      }
      Map<String, String> code2 = {};
      if (point != null) {
        code2 = {
          "code": point!.discountCoupon!,
        };
        listCode.add(code2);
      }
      order = place.PlaceOrderModel(
          id: selectedCustomer!.id,
          lineItems: lineItems,
          billingAddress: billing,
          shippingLines: shipping,
          paymentMethod: paymentMethod,
          couponCode: listCode,
          orderNote: orderNotes);
      var jsonOrder = json.encode(order);
      cartV2 = order;
      valid = true;
    } else {
      valid = false;
    }
    notifyListeners();
    return valid;
  }

  Future<void> submitOrder(
      {required CheckoutModel? order,
      required Function(String, bool) onSubmit}) async {
    isLoading = true;
    notifyListeners();

    final result = await _createOrderUsecase(CreateOrderParams(order: order!));

    result.fold(
      (l) {
        isLoading = false;
      },
      (r) {
        String _status;
        if (r!['id'] != null) {
          _status = 'success';
          printLog(json.encode(r), name: "Hllo");
          dataPrint = OrderPrint.friomJson(r);
          printLog(json.encode(dataPrint), name: "Waoooasdas");
          resetCartData();
        } else {
          _status = r['message'];
        }
        isLoading = false;
        getCart();
        onSubmit(_status, isLoading);
      },
    );

    notifyListeners();
  }

  Future<void> placeOrder(
      {place.PlaceOrderModel? order,
      required Function(String, bool) onSubmit}) async {
    isLoading = true;
    notifyListeners();

    final result = await _placeOrderUsecase(PlaceOrderParams(order: order!));

    result.fold(
      (l) {
        isLoading = false;
      },
      (r) {
        String _status;
        if (r['id'] != null) {
          _status = 'success';
          printLog(json.encode(r), name: "Hllo");
          dataPrint = OrderPrint.friomJson(r);

          printLog(json.encode(dataPrint), name: "Waoooasdas");
          resetCartData();
        } else {
          _status = r['message'];
        }
        isLoading = false;
        getCart();
        onSubmit(_status, isLoading);
      },
    );

    notifyListeners();
  }

  setTotal(double value) {
    total = value;
    notifyListeners();
  }

  setChanges(double value) {
    changes = value;
    notifyListeners();
  }

  setCustomer(Customer? value) {
    selectedCustomer = value;
    point = null;
    notifyListeners();
  }

  setSelectedCustomer(Customer value) {
    selectedCustomer = value;
    notifyListeners();
  }

  setOrderNotes(String value) {
    orderNotes = value;
    AppConfig.data!.setString('order_notes', orderNotes!);
    notifyListeners();
  }

  getOrderNotes() {
    if (AppConfig.data!.containsKey('order_notes')) {
      orderNotes = AppConfig.data!.getString('order_notes');
    } else {
      orderNotes = '';
    }
    notifyListeners();
  }

  reset() {
    changes = 0;
    notifyListeners();
  }

  resetCartData() {
    customer = null;
    selectedCustomer = null;
    cartProduct.clear();
    orderNotes = '';
    selectedShipping = "Select Shipping Method";
    selectedShippingMethod = null;
    totalPrice = 0;
    grandTotal = 0;
    totalItems = 0;
    couponStatus = '';
    selectedCoupon = null;
    discountAmount = 0;
    point = null;
    AppConfig.data!.remove('user_cart');
    AppConfig.data!.remove('order_notes');

    notifyListeners();
  }
}
