import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists_detail.dart';
import 'package:revo_pos/layers/domain/repositories/chat_repository.dart';

class GetChatListsDetailUsecase
    implements UseCase<List<ChatListsDetail>, ChatListsDetailParams> {
  final ChatRepository repository;

  GetChatListsDetailUsecase(this.repository);

  @override
  Future<Either<Failure, List<ChatListsDetail>>> call(
      ChatListsDetailParams params) async {
    return await repository.chatListsDetail(
        chatID: params.chatID, receiverID: params.receiverID);
  }
}

class ChatListsDetailParams extends Equatable {
  final int chatID;
  final int receiverID;
  const ChatListsDetailParams({required this.chatID, required this.receiverID});

  @override
  List<Object> get props => [chatID, receiverID];
}
