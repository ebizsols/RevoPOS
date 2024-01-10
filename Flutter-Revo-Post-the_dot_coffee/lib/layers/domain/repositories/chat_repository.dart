import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/setting_model.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists_detail.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatLists>>> chatLists(
      {String? search, int? page, int? perPage});
  Future<Either<Failure, Status>> sendChat(
      {String? message,
      int? receiverId,
      int? postId,
      String? type,
      String? image});
  Future<Either<Failure, List<ChatListsDetail>>> chatListsDetail(
      {int? chatID, int? receiverID});
  Future<Either<Failure, List<SettingModel>>> getSettings();
}
