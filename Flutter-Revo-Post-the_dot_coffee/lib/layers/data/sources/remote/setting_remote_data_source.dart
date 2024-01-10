import 'dart:convert';

import 'package:http/http.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/setting_model.dart';
import 'package:revo_pos/layers/data/models/user_setting_model.dart';

abstract class SettingRemoteDataSource {
  Future<List<SettingModel>> getSettings();

  Future<UserSettingModel> getUserSettings();
}

class SettingRemoteDataSourceImpl implements SettingRemoteDataSource {
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
      printLog('Error');
      throw UnimplementedError();
    }
  }

  @override
  Future<UserSettingModel> getUserSettings() async {
    var body;
    try {
      var response = await baseAPI!.getAsync(
          '/wp-json/revo-post/home-api/general-settings',
          isSetting: true,
          printedLog: true);

      if (response != null) {
        body = json.decode((response as Response).body);
      } else {
        throw ServerException();
      }

      return UserSettingModel.fromJson(body);
    } catch (e) {
      printLog(e.toString());
      throw UnimplementedError();
    }
  }
}
