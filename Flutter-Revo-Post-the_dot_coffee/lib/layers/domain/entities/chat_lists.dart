import 'package:equatable/equatable.dart';

class ChatLists extends Equatable {
  final String? id;
  final String? receiverId;
  final String? photo;
  final String? userName;
  final String? fullName;
  final String? status;
  final String? lastMessage;
  final String? time;
  final String? unread;

  const ChatLists(
      {this.id,
      this.receiverId,
      this.photo,
      this.userName,
      this.fullName,
      this.status,
      this.lastMessage,
      this.time,
      this.unread});

  factory ChatLists.fromJson(Map<String, dynamic> json) {
    return ChatLists(
      id: json['id'],
      receiverId: json['receiver_id'],
      photo: json['photo'],
      userName: json['user_name'],
      fullName: json['full_name'],
      status: json['status'],
      lastMessage: json['last_message'],
      time: json['time'],
      unread: json['unread'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['receiver_id'] = receiverId;
    data['photo'] = photo;
    data['user_name'] = userName;
    data['full_name'] = fullName;
    data['status'] = status;
    data['last_message'] = lastMessage;
    data['time'] = time;
    data['unread'] = unread;
    return data;
  }

  @override
  List<Object?> get props => [
        id,
        receiverId,
        photo,
        userName,
        fullName,
        status,
        lastMessage,
        time,
        unread
      ];
}
