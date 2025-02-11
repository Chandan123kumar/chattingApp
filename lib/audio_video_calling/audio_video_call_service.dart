import 'package:bat_karo/controller/device_token_service.dart';
import 'package:bat_karo/controller/notification_services.dart';
import 'package:bat_karo/model/audio_call_model.dart';
import 'package:bat_karo/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis/cloudsearch/v1.dart';
import 'package:random_string/random_string.dart';

class RequestCallService {
  final DeviceTokenService deviceTokenService = DeviceTokenService();
  final DatabaseReference reference = FirebaseDatabase.instance.ref(
      "callRequest");

  Future<void> sendCallRequest(String receiverID, String callID) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String? senderName = FirebaseAuth.instance.currentUser?.displayName;

    if (uid == null || senderName == null) return;

    await reference.child(receiverID).set({
      "callerId": uid,
      "call_id": callID,
      "callerName": senderName,
      "dateTIme": DateTime.now().toIso8601String()
    });

    DatabaseReference userRef = FirebaseDatabase.instance.ref(
        "callRequest/receiverID");
    DatabaseEvent event = await userRef.once();
    if (event.snapshot.exists) {
      Map userData = event.snapshot.value as Map;
      String? receiverToken = deviceTokenService.storeDeviceToken().toString();
      if (receiverToken != null) {
        await NotificationServices().sendCallNotification(
            callerID: callID, token: receiverToken, callerName: senderName);
      }
    }
  }

  Stream<DatabaseEvent> listenForIncomingcall(String userID) {
    return reference
        .child(userID)
        .onValue;
  }

  Future<void> removeCallRequest(String userId) async {
    await reference.child(userId).remove();
  }

}
