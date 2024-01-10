import 'package:dartz/dartz.dart';
import 'package:revo_pos/core/error/exceptions.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/layers/data/models/setting_model.dart';
import 'package:revo_pos/layers/data/sources/remote/chat_remote_data_source.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists_detail.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';
import 'package:revo_pos/layers/domain/repositories/chat_repository.dart';

typedef _ChatListsLoader = Future<List<ChatLists>> Function();
typedef _SendChatLoader = Future<Status> Function();
typedef _ChatListsDetailLoader = Future<List<ChatListsDetail>> Function();

class ChatRepositoryImpl extends ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ChatLists>>> chatLists(
      {String? search, int? page, int? perPage}) async {
    return await _chatLists(() {
      return remoteDataSource.listChat(
          page: page, perPage: perPage, search: search);
    });
  }

  Future<Either<Failure, List<ChatLists>>> _chatLists(
      _ChatListsLoader chatLists) async {
    try {
      final remote = await chatLists();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<SettingModel>>> getSettings() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Status>> sendChat(
      {String? message,
      int? receiverId,
      int? postId,
      String? type,
      String? image}) async {
    return await _sendChat(() {
      return remoteDataSource.sendChat(
          receiverId: receiverId,
          postId: postId,
          image: image,
          message: message,
          type: type);
    });
  }

  Future<Either<Failure, Status>> _sendChat(_SendChatLoader sendChat) async {
    try {
      final remote = await sendChat();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatListsDetail>>> chatListsDetail(
      {int? chatID, int? receiverID}) async {
    return await _chatListsDetail(() {
      return remoteDataSource.listChatDetail(
          chatID: chatID, receiverID: receiverID);
    });
  }

  Future<Either<Failure, List<ChatListsDetail>>> _chatListsDetail(
      _ChatListsDetailLoader chatListsDetail) async {
    try {
      final remote = await chatListsDetail();
      return Right(remote);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
