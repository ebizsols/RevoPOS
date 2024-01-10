import 'package:equatable/equatable.dart';

class ChatListsDetail extends Equatable {
  final String? date;
  final List<ChatDetail>? chatDetail;

  const ChatListsDetail({this.date, this.chatDetail});

  factory ChatListsDetail.fromJson(Map<String, dynamic> json) {
    var chat;
    if (json["chat"] != null) {
      chat = List.generate(json['chat'].length,
          (index) => ChatDetail.fromJson(json['chat'][index]));
    }
    return ChatListsDetail(date: json['date'], chatDetail: chat);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['chat'] = chatDetail;
    return data;
  }

  @override
  List<Object?> get props => [date, chatDetail];
}

class ChatDetail extends Equatable {
  final String? chatId;
  final String? senderId;
  final String? receiverId;
  final String? message;
  final String? type;
  final String? image;
  final String? postId;
  final String? typeMessage;
  final String? status;
  final String? potition;
  final String? createdAt;
  final String? time;
  final Subject? subject;

  const ChatDetail(
      {this.chatId,
      this.senderId,
      this.receiverId,
      this.message,
      this.type,
      this.image,
      this.postId,
      this.typeMessage,
      this.status,
      this.potition,
      this.createdAt,
      this.time,
      this.subject});

  factory ChatDetail.fromJson(Map<String, dynamic> json) {
    return ChatDetail(
        chatId: json['chat_id'],
        senderId: json['sender_id'],
        receiverId: json['receiver_id'],
        message: json['message'],
        type: json['type'],
        image: json['image'],
        postId: json['post_id'],
        typeMessage: json['type_message'],
        status: json['status'],
        potition: json['potition'],
        createdAt: json['created_at'],
        time: json['time'],
        subject:
            json["subject"] != null ? Subject.fromJson(json["subject"]) : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chat_id'] = chatId;
    data['sender_id'] = senderId;
    data['receiver_id'] = receiverId;
    data['message'] = message;
    data['type'] = type;
    data['image'] = image;
    data['post_id'] = postId;
    data['type_message'] = typeMessage;
    data['status'] = status;
    data['potition'] = potition;
    data['created_at'] = createdAt;
    data['time'] = time;
    data['subject'] = subject;
    return data;
  }

  @override
  List<Object?> get props => [
        chatId,
        senderId,
        receiverId,
        message,
        type,
        image,
        postId,
        typeMessage,
        status,
        potition,
        createdAt,
        time,
        subject
      ];
}

class Subject extends Equatable {
  final int? id;
  final String? name;
  final String? status;
  final String? price;
  final String? imageFirst;

  const Subject({this.id, this.name, this.status, this.price, this.imageFirst});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
        id: json['id'],
        name: json['name'],
        status: json['status'],
        price: json['price'].toString(),
        imageFirst: json['image_first'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['price'] = price;
    data['image_first'] = imageFirst;
    return data;
  }

  @override
  List<Object?> get props => [id, name, status, price, imageFirst];
}
