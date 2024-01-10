import 'package:flutter/cupertino.dart';
import 'package:revo_pos/core/constant/constants.dart';
//import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists_detail.dart';
import 'package:revo_pos/layers/domain/entities/login.dart';
import 'package:revo_pos/layers/domain/entities/product_image.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';
import 'package:revo_pos/layers/domain/usecases/auth/get_settings_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/chat/get_chat_lists_detail_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/chat/get_chat_lists_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/chat/send_chat_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/insert_image_usecase.dart';

class ChatNotifier with ChangeNotifier {
  final GetChatListsUsecase _chatListsUsecase;
  final GetChatListsDetailUsecase _chatDetailListUsecase;
  final SendChatUsecase _sendChatUsecase;
  final InsertImageUsecase _insertImageUsecase;

  bool isLoading = false;
  bool loadingChat = false;
  bool loadingSend = false;
  Status? status;
  String? version;

  Login? user;
  List<ChatLists>? chatLists = [];
  List<ChatListsDetail> detailChatList = [];
  List<ChatLists>? tempChatLists;

  int chatPage = 1;

  ChatNotifier(
      {required GetChatListsUsecase chatListsUsecase,
      required GetSettingsUsecase settingsUsecase,
      required GetChatListsDetailUsecase chatDetailListUsecase,
      required SendChatUsecase sendChatUsecase,
      required InsertImageUsecase insertImageUsecase})
      : _chatListsUsecase = chatListsUsecase,
        _chatDetailListUsecase = chatDetailListUsecase,
        _sendChatUsecase = sendChatUsecase,
        _insertImageUsecase = insertImageUsecase;

  Future<void> getChatLists({String? search}) async {
    isLoading = true;
    notifyListeners();

    final result = await _chatListsUsecase(
        ChatListsParams(page: 1, perPage: 50, search: search!));

    result.fold(
      (e) {
        printLog('Failed');
        chatLists = [];
        isLoading = false;
      },
      (r) {
        printLog('Success');
        tempChatLists = [];
        tempChatLists!.addAll(r);
        List<ChatLists> list = List.from(chatLists!);
        list.addAll(tempChatLists!);
        chatLists = list;
        if (tempChatLists!.length % 10 == 0) {
          chatPage++;
        }
      },
    );
    isLoading = false;
    notifyListeners();
  }

  Future<Status> sendChat(
      {String? message,
      String? types,
      int? postID,
      int? receiverID,
      String? image}) async {
    loadingSend = true;
    notifyListeners();
    final result = await _sendChatUsecase(SendChatParams(
        message: message!,
        type: types!,
        postId: postID!,
        receiverId: receiverID!,
        image: image!));
    printLog("ReceiverID : ${receiverID} - type : ${types}");
    printLog("Result : ${result.toString()}");
    result.fold((l) {
      printLog("Failed to send");
    }, (r) {
      status = r;
      printLog("status send: ${status}");
    });
    loadingSend = false;
    notifyListeners();

    return status!;
  }

  int? receiverId;
  Future<void> getDetailChat({int? chatID, int? receiverID}) async {
    loadingChat = true;
    notifyListeners();
    final result = await _chatDetailListUsecase(
        ChatListsDetailParams(chatID: chatID!, receiverID: receiverID!));

    result.fold(
      (e) {
        printLog('Failed');
        detailChatList = [];
        loadingChat = false;
        notifyListeners();
      },
      (r) {
        printLog('Success');
        detailChatList = [];
        detailChatList.addAll(r);
        printLog("Detail Chat : ${detailChatList}");
        if (detailChatList.isNotEmpty) {
          receiverId = int.parse(detailChatList[0].chatDetail![0].receiverId!);
        }
        printLog("receiverID : $receiverId");
        loadingChat = false;
        notifyListeners();
      },
    );
  }

  resetPage() {
    chatPage = 1;
    chatLists = [];
    isLoading = true;
    notifyListeners();
  }

  uploadImage({String? title, String? image}) async {
    final result = await _insertImageUsecase(
        InsertImageParams(title: title!, image: image!));
    var _status;
    result.fold((l) {
      printLog("Failed to send");
    }, (r) {
      _status = r;
      printLog("status send image: ${_status}");
    });
    loadingSend = false;
    notifyListeners();

    return _status;
  }
}
