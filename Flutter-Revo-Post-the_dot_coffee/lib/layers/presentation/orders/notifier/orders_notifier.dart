import 'package:flutter/cupertino.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/order_model.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';
import 'package:revo_pos/layers/domain/entities/payment_gateway.dart';
import 'package:revo_pos/layers/domain/usecases/order/get_order_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/get_payment_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/update_status_order_usecase.dart';

class OrdersNotifier with ChangeNotifier {
  final GetOrderUsecase _getOrderUsecase;
  final UpdateStatusOrderUsecase _updateStatusOrderUsecase;
  final GetPaymentUsecase _getPaymentUsecase;

  OrdersNotifier({
    required GetOrderUsecase getOrderUsecase,
    required UpdateStatusOrderUsecase updateStatusOrderUsecase,
    required GetPaymentUsecase getPaymentUsecase,
  })  : _getOrderUsecase = getOrderUsecase,
        _updateStatusOrderUsecase = updateStatusOrderUsecase,
        _getPaymentUsecase = getPaymentUsecase;

  List<Orders>? orders = [];
  List<Orders>? tempList;

  bool isLoading = true;
  int orderPage = 1;
  int ordersLimit = 10;
  OrderModel? order;

  int selectedStatus = 0;
  String status = '';

  List<PaymentGateway>? payments = [];

  setSelectedStatus(int value) {
    selectedStatus = value;
    switch (selectedStatus) {
      case 0:
        {
          status = '';
        }
        break;
      case 1:
        {
          status = 'pending';
        }
        break;
      case 2:
        {
          status = 'on-hold';
        }
        break;
      case 3:
        {
          status = 'processing';
        }
        break;
      case 4:
        {
          status = 'completed';
        }
        break;
      case 5:
        {
          status = 'cancelled';
        }
        break;
      default:
        {
          status = '';
        }
        break;
    }
    notifyListeners();
  }

  Future<void> getOrders({required String search}) async {
    isLoading = true;
    notifyListeners();

    final result = await _getOrderUsecase(OrderParams(
        search: search, page: orderPage, perPage: ordersLimit, status: status));

    result.fold((l) {
      orders = [];
      isLoading = false;
    }, (r) {
      tempList = [];
      tempList!.addAll(r);
      List<Orders> list = List.from(orders!);
      list.addAll(tempList!);
      orders = list;
      if (tempList!.length % 10 == 0) {
        orderPage++;
      }
      isLoading = false;
    });

    notifyListeners();
  }

  Future<void> updateStatusOrder(
      {required int id,
      required Function(Map<String, dynamic>, bool) onSubmit}) async {
    isLoading = true;
    notifyListeners();

    final result = await _updateStatusOrderUsecase(
        UpdateStatusOrderParams(status: status, id: id));

    result.fold((l) {
      Map<String, dynamic> data = {
        "message": 'Error when updating order status'
      };
      isLoading = false;
      printLog('Failed');
      onSubmit(data, isLoading);
    }, (r) {
      isLoading = false;
      onSubmit(r!, isLoading);
      printLog('Success');
    });

    isLoading = false;
    notifyListeners();
  }

  Future<void> getPayments() async {
    isLoading = true;
    notifyListeners();

    final result = await _getPaymentUsecase(NoParams());

    result.fold((l) {
      payments = [];
      isLoading = false;
      printLog("Payment failed");
    }, (r) {
      payments = [];
      payments!.add(PaymentGateway(id: 'cod', methodTitle: "Cash on Delivery"));
      for (var element in r) {
        if (element.enabled!) {
          printLog(element.methodTitle!, name: 'Payment Name');
          if (element.id! == "bacs") {
            payments!.add(element);
          }
          if (element.id! == "cheque") {
            payments!.add(element);
          }
        }
      }
    });

    isLoading = false;
    notifyListeners();
  }

  updateLimit(int value) {
    ordersLimit = value;
    notifyListeners();
  }

  setLoading() {
    isLoading = true;
    notifyListeners();
  }

  resetPage() {
    orderPage = 1;
    orders = [];
    tempList = [];
    isLoading = true;
    notifyListeners();
  }
}
