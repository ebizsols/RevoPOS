import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:revo_pos/core/error/failures.dart';
import 'package:revo_pos/core/usecase/usecase.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/domain/entities/status.dart';
import 'package:revo_pos/layers/domain/repositories/chat_repository.dart';

class SendChatUsecase extends UseCase<Status, SendChatParams> {
  final ChatRepository repository;

  SendChatUsecase(this.repository);

  @override
  Future<Either<Failure, Status>> call(SendChatParams params) async {
    return await repository.sendChat(
        message: params.message,
        image: params.image,
        postId: params.postId,
        receiverId: params.receiverId,
        type: params.type);
  }
}

class SendChatParams extends Equatable {
  final String message, type, image;
  final int receiverId, postId;

  const SendChatParams(
      {required this.message,
      required this.type,
      required this.image,
      required this.receiverId,
      required this.postId});

  @override
  List<Object> get props => [message, type, image, receiverId, postId];
}
