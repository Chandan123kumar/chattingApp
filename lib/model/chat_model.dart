import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  String? senderId;
  String? receiverId;
  String? message;
  String? status;
  String? imageUrl;
  DateTime? dateTime;
  String? messageType;


  ChatModel({
    this.senderId,
    this.receiverId,
    this.message,
    this.status,
    this.imageUrl,
    this.dateTime,
    this.messageType
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    senderId: json["sender_id"],
    receiverId: json["receiver_id"],
    message: json["message"],
    status: json["status"],
    imageUrl: 'imageUrl',
    dateTime: json["dateTime"] != null
        ? DateTime.parse(json["dateTime"])
        : null,
      messageType: json['messageType']
  );


  Map<String, dynamic> toJson() => {
  "sender_id": senderId,
  "receiver_id": receiverId,
  "message": message,
  "status": status,
  "imageUrl":imageUrl,
  "dateTime": DateTime.timestamp().toIso8601String(),
    "messageType": messageType
  };
}