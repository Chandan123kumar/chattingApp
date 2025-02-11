import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserStatusManager {
  final database = FirebaseDatabase.instance.ref('users');

  void setUserStatus(bool isOnline) async {
    String uId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference statusRef = database.child(uId).child('status');
    if (isOnline) {
      await statusRef.set({
        "Online": true,
        "lastSeen": DateTime.now().toIso8601String(),
      });
    } else {
      await statusRef.update({
        "Online": false,
        "lastSeen": DateTime.now().toIso8601String(),
      });
    }
  }

  void monitorConnection() {
    String uId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference statusRef = database.child(uId).child('status');
    statusRef.onDisconnect().update({
      "Online": false,
      "lastSeen": DateTime.now().toIso8601String(),
    });
  }
}
