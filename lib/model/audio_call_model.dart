import 'package:meta/meta.dart';
import 'dart:convert';

AudioCallModel audioCallModelFromJson(String str) =>
    AudioCallModel.fromJson(json.decode(str));

String audioCallModelToJson(AudioCallModel data) => json.encode(data.toJson());

class AudioCallModel {
  String? id;
  String? callerName;
  String? callerEmail;
  String? callerPic;
  String? callerUid;
  String? receiverUid;
  String? receiverName;
  String? receiverEmail;
  String? receiverPic;
  String? status;

  AudioCallModel({
    this.id,
    this.callerName,
    this.callerEmail,
    this.callerPic,
    this.callerUid,
    this.receiverUid,
    this.receiverName,
    this.receiverEmail,
    this.receiverPic,
    this.status,
  });

  factory AudioCallModel.fromJson(Map<String, dynamic> json) =>
      AudioCallModel(
        id: json["id"],
        callerName: json["callerName"],
        callerEmail: json["callerEmail"],
        callerPic: json["callerPic"],
        callerUid: json["callerUid"],
        receiverUid: json["receiverUid"],
        receiverName: json["receiverName"],
        receiverEmail: json["receiverEmail"],
        receiverPic: json["receiverPic"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "callerName": callerName,
        "callerEmail": callerEmail,
        "callerPic": callerPic,
        "callerUid": callerUid,
        "receiverUid": receiverUid,
        "receiverName": receiverName,
        "receiverEmail": receiverEmail,
        "receiverPic": receiverPic,
        "status": status,
      };
}
