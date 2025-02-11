import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/chat_model.dart';
import '../model/user_model.dart';
import 'device_token_service.dart';
import 'notification_services.dart';

class ChatViewModel with ChangeNotifier {
  final TextEditingController chatController = TextEditingController();
  final String chatHint = "Enter message";
  var chatList = <ChatModel>[];
  var userList = <UserModel>[];
  var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  String otherUId = "";
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationServices notificationServices = NotificationServices();
  DeviceTokenService deviceTokenService = DeviceTokenService();
  final _auth = FirebaseAuth.instance.currentUser!;
  final ImagePicker _picker = ImagePicker();
  File? _selectImage;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  getChatList({required String cid, required String otherId}) {
    var chatId = getChatId(cid: cid, otherId: otherId);

    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('messages/$chatId');
    starCountRef.orderByChild('dateTime').onValue.listen((DatabaseEvent event) {
      chatList.clear();
      var data = event.snapshot.children;
      for (var element in data) {
        var chat = ChatModel(
          senderId: element.child("sender_id").value.toString(),
          receiverId: element.child("receiver_id").value.toString(),
          message: element.child("message").value.toString(),
          status: element.child("status").value.toString(),
          imageUrl: element.child('imageUrl').value.toString(),
          dateTime: element.child("dateTime").value != null
              ? DateTime.parse(element.child('dateTime').value.toString())
              : null,
        );
        chatList.add(chat);
      }
      notifyListeners();
    });
  }

  Future<void> sendChat(
      {required String otherUid, String? message, File? image}) async {
    var cid = uid.toString();
    var chatId = getChatId(otherId: otherUid, cid: cid);
    var timeStamp = DateTime.now().toIso8601String();
    var randomId = generateRandomString(40);
    String? imageUrl;
    String messageType = "text";
    if (image != null) {
      imageUrl = await uploadImageToStorage(image);
      messageType = "image";
    }

    DatabaseReference chatRef = FirebaseDatabase.instance.ref(
        'messages/$chatId');

    DatabaseReference userRef = FirebaseDatabase.instance.ref("user/$cid");
    var userSnapshot = await userRef.get();

    String senderName = userSnapshot.exists
        ? userSnapshot.child("name").value?.toString() ?? "Unknown Person"
        : "Unknown";

    await chatRef.child(randomId).set(ChatModel(
      message: image == null ? chatController.text.trim() : null,
      senderId: uid,
      receiverId: otherUid,
      messageType: messageType,
      imageUrl: imageUrl,
      dateTime: DateTime.now(),
            status = 'sent')
        .toJson());

    String? deviceToken =
        await deviceTokenService.getDeviceTokenFromFirebase(otherUid);
    if (deviceToken != null) {
      await notificationServices.sendOrderNotification(
        message: image != null ? "[Image]" : chatController.text,
        token: deviceToken,
        senderName: senderName,
      );
    }

    chatController.clear();
    notifyListeners();
  }


  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  getUserList() {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('user');
    starCountRef.onValue.listen((DatabaseEvent event) {
      var data = event.snapshot.children;
      userList.clear();
      data.forEach(
        (element) {
          var user = UserModel(
            name: element.child("name").value.toString(),
            email: element.child("email").value.toString(),
            id: element.child("id").value.toString(),
          );
          userList.add(user);
        },
      );
      notifyListeners();
    });
  }


  Future<String> uploadImageToStorage(File image) async {
    try {
      String fileName = "${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg";
      final storageRef = FirebaseStorage.instance.ref().child(
          'chat_images/$uid/$fileName');

      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }


  pickAndSendImage(String otherUid) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      await sendChat(otherUid: otherUid, image: image);
    }
  }

  Future<void> getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser?.uid;
    if (currentUser == null) {
      print('No user is logedIn');
      return;
    }
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref(
          "user/$currentUser");
      final dataSnapshot = await ref.get();
      if (dataSnapshot.exists) {
        _currentUser = UserModel.fromJson(
            Map<String, dynamic>.from(dataSnapshot.value as Map));
        notifyListeners();
      }
      else {
        print('No data found for current user');
      }
    } catch (ex) {
      print('error $ex');
    }
  }

  Future<void> deleteChatMessage(String chatId, String messageId) async {
    DatabaseReference deleteRef =
    FirebaseDatabase.instance.ref('messages/$chatId/$messageId');
    await deleteRef.remove();
  }

  String getChatId({required String cid, required String otherId}) {
    var id = "";
    if (cid.compareTo(otherId) > 0) {
      id = "${cid}_$otherId";
    } else {
      id = "${otherId}_$cid";
    }
    FirebaseDatabase.instance.ref('messages').child(id).get().then((value) {
      if (value.exists) {} else {
        var chatId =
        FirebaseDatabase.instance.ref().child("messages").child(id).set(id);
        print(chatId);
      }
    });
    return id;
  }
}


