import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/login_model.dart';
import 'package:revo_pos/layers/data/models/setting_model.dart';
import 'package:revo_pos/layers/domain/entities/login.dart';
import 'package:revo_pos/layers/domain/usecases/auth/get_settings_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/auth/login_usecase.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';

class LoginNotifier with ChangeNotifier {
  final LoginUsecase _loginUsecase;
  final GetSettingsUsecase _settingsUsecase;

  bool isHidePassword = true;
  bool isRememberMe = false;
  bool isEnabled = false;
  bool isLoading = false;
  String? version;

  Login? user;
  SettingModel? currencySymbol;
  SettingModel? thousandSeparator;
  SettingModel? decimalSeparator;
  SettingModel? decimalNumber;

  LoginNotifier(
      {required LoginUsecase loginUsecase,
      required GetSettingsUsecase settingsUsecase})
      : _loginUsecase = loginUsecase,
        _settingsUsecase = settingsUsecase;

  Future<void> getVersion() async {
    final result = await PackageInfo.fromPlatform();

    version = result.version;
    notifyListeners();
  }

  setShowPassword(bool value) {
    isHidePassword = value;
    notifyListeners();
  }

  setRememberMe(bool value) {
    AppConfig.data?.setBool('isRememberMe', value);
    isRememberMe = value;
    notifyListeners();
  }

  setEnabled(bool value) {
    isEnabled = value;
    notifyListeners();
  }

  Future<void> login(context,
      {required String username,
      required String password,
      required Function(Login, bool, Map<String, dynamic>) onSubmit}) async {
    isLoading = true;
    notifyListeners();

    Map<String, dynamic> resultResponse = {};

    final result = await _loginUsecase(LoginParams(
      username: username,
      password: password,
    ));

    result.fold(
      (e) {
        isLoading = false;
        onSubmit(user!, isLoading, resultResponse);
      },
      (r) {
        if (r['cookie'] != null) {
          user = LoginModel.fromJson(r);
          AppConfig.data?.setString('user_data', json.encode(r));
          printLog(user!.user!.role![0], name: "Login data");
          if (user!.user!.role![0] == "shop_manager") {
            Provider.of<MainNotifier>(context, listen: false)
                .removeReportPage(context);
          }
        } else if (r['message'] != null) {
          user = const LoginModel(user: null, cookie: '');
          resultResponse = r;
          isLoading = false;
        }
        onSubmit(user!, isLoading, resultResponse);
      },
    );

    notifyListeners();
  }

  Future<void> getSettings({required Function(bool) onSubmit}) async {
    notifyListeners();

    final result = await _settingsUsecase(NoParams());

    result.fold(
      (e) {
        printLog('Failed');
        isLoading = false;
      },
      (r) {
        printLog('Success');
        // printLog(json.encode(r), name: "Awak");
        for (var element in r) {
          if (element.id == 'woocommerce_currency') {
            currencySymbol = element;
          } else if (element.id == 'woocommerce_price_thousand_sep') {
            thousandSeparator = element;
          } else if (element.id == 'woocommerce_price_decimal_sep') {
            decimalSeparator = element;
          } else if (element.id == 'woocommerce_price_num_decimals') {
            decimalNumber = element;
          }
        }
        isLoading = false;
        onSubmit(isLoading);
      },
    );

    notifyListeners();
  }

  setUserData() {
    dynamic jsonUser = json.decode(AppConfig.data!.getString('user_data')!);
    final value = LoginModel.fromJson(jsonUser);
    user = value;
    notifyListeners();
  }
}
