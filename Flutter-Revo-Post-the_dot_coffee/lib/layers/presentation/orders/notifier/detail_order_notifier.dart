import 'package:flutter/material.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/domain/entities/user_setting.dart';
import 'package:revo_pos/layers/domain/usecases/customer/get_customer_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/print_inv_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/setting/user_settings_usecase.dart';

class DetailOrderNotifier with ChangeNotifier {
  final PrintInvUsecase _printInvUsecase;
  final GetUserSettingsUsecase _userSettingsUsecase;
  final GetCustomerUsecase _getCustomerUsecase;

  DetailOrderNotifier({
    required PrintInvUsecase printInvUsecase,
    required GetUserSettingsUsecase userSettingsUsecase,
    required GetCustomerUsecase getCustomerUsecase,
  })  : _printInvUsecase = printInvUsecase,
        _getCustomerUsecase = getCustomerUsecase,
        _userSettingsUsecase = userSettingsUsecase;

  List<String> statuses = [
    "Pending Payment",
    "On Hold",
    "Processing",
    "Completed"
  ];
  int selectedStatus = 0;

  bool isLoadingPrintInv = false;
  String? urlInv;

  UserSetting? userSetting;
  int selectedStatusDetail = 0;

  setSelectedStatus(int value) {
    selectedStatus = value;
    notifyListeners();
  }

  setSelectedStatusDetail(String value) {
    switch (value) {
      case 'pending':
        {
          selectedStatusDetail = 0;
        }
        break;
      case 'on-hold':
        {
          selectedStatusDetail = 1;
        }
        break;
      case 'processing':
        {
          selectedStatusDetail = 2;
        }
        break;
      case 'completed':
        {
          selectedStatusDetail = 3;
        }
        break;
      case 'cancelled':
        {
          selectedStatusDetail = 4;
        }
        break;
      default:
        {
          selectedStatusDetail = 0;
        }
        break;
    }
    notifyListeners();
  }

  bool isLoading = false;
  Customer? customer;
  Future<void> getDetailCustomer(int id) async {
    isLoading = true;
    notifyListeners();

    final result =
        await _getCustomerUsecase(SingleCustomerParams(customerID: id));

    result.fold((l) {
      isLoading = false;
      notifyListeners();
    }, (r) {
      customer = r;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<Map<String, dynamic>?> printInv(
      {required int idOrder,
      required String storeName,
      required String storePhone,
      required String storeAlamat}) async {
    isLoadingPrintInv = true;
    notifyListeners();

    final result = await _printInvUsecase(PrintInvParams(
        cookie: AppConfig.data!.getString('cookie')!,
        idOrder: idOrder,
        storeName: storeName,
        storePhone: storePhone,
        storeAlamat: storeAlamat));

    result.fold((l) {
      printLog('Failed');
    }, (r) {
      printLog('Success');
      urlInv = r?["inv_url"];
    });

    isLoadingPrintInv = false;
    notifyListeners();
    return null;
  }

  bool loadingSetting = true;
  Future<void> getUserSettings() async {
    final result = await _userSettingsUsecase(NoParams());

    result.fold((l) {
      printLog('Failed');
    }, (r) {
      userSetting = r;
      loadingSetting = false;
      notifyListeners();
    });

    notifyListeners();
  }
}
