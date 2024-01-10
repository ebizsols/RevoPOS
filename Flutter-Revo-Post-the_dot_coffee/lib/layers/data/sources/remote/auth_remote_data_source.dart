import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/setting_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({String? username, String? password});
  Future<List<SettingModel>> getSettings();
  Future<Map<String, dynamic>> checkValidateCookie();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<Map<String, dynamic>> login(
      {String? username, String? password}) async {
    try {
      Map<String, dynamic> result;

      Map data = {'username': username, 'password': password};
      var response = await baseAPI!.postAsync('generate_auth_cookie', data,
          isCustom: true, printedLog: true);
      printLog(response.toString());
      result = response;

      if (response['cookie'] != null) {
        await AppConfig.data!.setString('cookie', response['cookie']);
        var url = "home-api/input-token-firebase";
        Map data = {
          "cookie": AppConfig.data!.getString('cookie'),
          "token": AppConfig.data!.getString("device_token")
        };
        var res = await baseAPI!.postAsync(url, data, isCustom: true);
        printLog("RES : ${res.toString()}");
      }

      return result;
    } catch (e) {
      log(e.toString());
      throw UnimplementedError();
    }
  }

  @override
  Future<Map<String, dynamic>> checkValidateCookie() async {
    try {
      Map<String, dynamic> result;

      Map data = {'cookie': AppConfig.data!.getString('cookie')};
      var response = await baseAPI!.postAsync('check-validate-cookie', data,
          isCustom: true, printedLog: true);
      printLog(response.toString());
      result = response;

      return result;
    } catch (e) {
      log(e.toString());
      throw UnimplementedError();
    }
  }

  @override
  Future<List<SettingModel>> getSettings() async {
    try {
      List settings = [];
      var response = await baseAPI!
          .getAsync('settings/general', isCustom: false, printedLog: false);
      printLog(response.toString());

      if (response != null) {
        settings = json.decode((response as Response).body);
      } else {
        throw ServerException();
      }

      return settings.map((setting) => SettingModel.fromJson(setting)).toList();
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }
}
