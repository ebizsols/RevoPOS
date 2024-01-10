import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/setting_model.dart';
import 'package:revo_pos/layers/data/models/status_model.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists_detail.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatLists>> listChat({String? search, int? page, int? perPage});
  Future<List<SettingModel>> getSettings();
  Future<Status> sendChat(
      {String? message,
      int? receiverId,
      int? postId,
      String? type,
      String? image});
  Future<List<ChatListsDetail>> listChatDetail({int? chatID, int? receiverID});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  @override
  Future<List<ChatLists>> listChat(
      {String? search, int? page, int? perPage}) async {
    try {
      List chatLists = [];

      Map data = {'cookie': AppConfig.data!.getString('cookie')};
      var response = await baseAPI!.postAsync('list-user-chat', data,
          isCustomRevoShop: true, printedLog: true);
      printLog(response.toString());

      if (response != null) {
        chatLists = response;
      } else {
        throw ServerException();
      }

      return chatLists.map((chat) => ChatLists.fromJson(chat)).toList();
    } catch (e) {
      log('Error');
      printLog(e.toString(), name: 'Error Chat');
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
      printLog('Error');
      throw UnimplementedError();
    }
  }

  @override
  Future<StatusModel> sendChat(
      {String? message,
      int? receiverId,
      int? postId,
      String? type,
      String? image}) async {
    var status;
    try {
      Map data = {
        'cookie': AppConfig.data!.getString('cookie'),
        'message': message,
        'type': type,
        'post_id': postId,
        'receiver_id': receiverId,
        'image': image
      };
      printLog("data : ${json.encode(data)}");
      Map<String, dynamic> result = {};
      var response = await baseAPI!.postAsync('insert-chat', data,
          isCustomRevoShop: true, printedLog: true);
      printLog("response : ${response.toString()}");

      if (response != null) {
        result = response;
      } else {
        throw ServerException();
      }
      if (response != null) {
        status = response;
      } else {
        throw ServerException();
      }
      printLog("status : ${status}");
      return StatusModel.fromJson(status);
    } catch (e) {
      log('Error');
      printLog(e.toString(), name: 'Error Chat');
      throw UnimplementedError();
    }
  }

  @override
  Future<List<ChatListsDetail>> listChatDetail(
      {int? chatID, int? receiverID}) async {
    try {
      List chatListsDetail = [];

      Map data = {
        'cookie': AppConfig.data!.getString('cookie'),
        'chat_id': chatID == 0 ? null : chatID,
        'receiver_id': receiverID == 0 ? null : receiverID
      };
      var response = await baseAPI!.postAsync('detail-chat', data,
          isCustomRevoShop: true, printedLog: true);
      printLog(response.toString());

      if (response != null) {
        chatListsDetail = response;
      } else {
        throw ServerException();
      }
      printLog("chat list : ${chatListsDetail}");
      return chatListsDetail
          .map((chat) => ChatListsDetail.fromJson(chat))
          .toList();
    } catch (e) {
      log('Error');
      printLog(e.toString(), name: 'Error Chat');
      throw UnimplementedError();
    }
  }
}
