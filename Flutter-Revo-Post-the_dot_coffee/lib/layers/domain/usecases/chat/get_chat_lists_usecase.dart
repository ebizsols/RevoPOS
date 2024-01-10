import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists.dart';
import 'package:revo_pos/layers/domain/repositories/chat_repository.dart';

class GetChatListsUsecase implements UseCase<List<ChatLists>, ChatListsParams> {
  final ChatRepository repository;

  GetChatListsUsecase(this.repository);

  @override
  Future<Either<Failure, List<ChatLists>>> call(ChatListsParams params) async {
    return await repository.chatLists(
        page: params.page, perPage: params.perPage, search: params.search);
  }
}

class ChatListsParams extends Equatable {
  final String search;
  final int page, perPage;

  const ChatListsParams(
      {required this.search, required this.page, required this.perPage});

  @override
  List<Object> get props => [search, page, perPage];
}
