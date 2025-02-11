import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserStatusManager {
  final database = FirebaseDatabase.instance.ref('users');
  Timer? _typingTimer;

  void setUserStatus({required bool isOnline, bool isTyping = false}) async {
    String uId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference statusRef = database.child(uId).child('status');
    if (isOnline) {
      await statusRef.set({
        "Online": true,
        "isTyping": isTyping,
        "lastSeen": DateTime.now().toIso8601String(),
      });
    }
  }

  void userOfflineStatus() {
    String uId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference statusRef = database.child(uId).child('status');
    statusRef.onDisconnect().update({
      "Online": false,
      "isTyping": false,
      "lastSeen": DateTime.now().toIso8601String(),
    });
  }

  void startTypingStatus() {
    setUserStatus(isOnline: true, isTyping: true);
    _typingTimer?.cancel();
    _typingTimer = Timer(
      const Duration(seconds: 2),
      () {
        stopTyping();
      },
    );
  }

  void stopTyping() {
    setUserStatus(isOnline: true, isTyping: false);
  }
}
