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


  getChatList({required String cid, required String otherId}) {
    var chatId = getChatId(cid: cid, otherId: otherId);

    DatabaseReference starCountRef =
    FirebaseDatabase.instance.ref('messages/$chatId');
    starCountRef
        .orderByChild('dateTime')
        .onValue
        .listen((DatabaseEvent event) {
      chatList.clear();
      var data = event.snapshot.children;
      data.forEach(
            (element) {
          var chat = ChatModel(
            senderId: element
                .child("sender_id")
                .value
                .toString(),
            receiverId: element
                .child("receiver_id")
                .value
                .toString(),
            message: element
                .child("message")
                .value
                .toString(),
            status: element
                .child("status")
                .value
                .toString(),
            imageUrl: element.child('imageUrl').value.toString(),
            dateTime: element
                .child("dateTime")
                .value != null ? DateTime.parse(element
                .child('dateTime')
                .value
                .toString()) : null,
          );
          chatList.add(chat);
        },
      );
      notifyListeners();
    });
  }

  sendChat(
      {required String otherUid, String? message, File? image}) async {
    var cid = uid.toString();
    var chatId = getChatId(otherId: otherUid, cid: cid);
    var timeStamp = DateTime.now().toIso8601String();
    var randomId = generateRandomString(40);
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref(
        'messages/$chatId');

    String? imageUrl;

    if (image != null) {
      imageUrl = await uploadImageToStorage(image);
    }

    //sent, seen, unseen
    await starCountRef.child(randomId).set(ChatModel(
        message: chatController.text.toString(),
        senderId: uid,
        receiverId: otherUid,
        status: timeStamp,
        imageUrl: imageUrl).toJson());

    String? deviceToken = await deviceTokenService.getDeviceTokenFromFirebase(
        otherUid);
    if (deviceToken != null && deviceToken.isNotEmpty) {
      await notificationServices.sendOrderNotification(
        message: message ??'Sent an image',
        token: deviceToken,
        senderName: _auth.displayName.toString(),);
    }

    chatController.clear();
    notifyListeners();
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  getUserList() {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('users');
    starCountRef.onValue.listen((DatabaseEvent event) {
      var data = event.snapshot.children;
      userList.clear();
      data.forEach(
            (element) {
          var user = UserModel(
            name: element
                .child("name")
                .value
                .toString(),
            email: element
                .child("email")
                .value
                .toString(),
            id: element
                .child("id")
                .value
                .toString(),
            // token: element.child('token').value.toString()
          );
          userList.add(user);
        },
      );
      notifyListeners();
    });
  }

  String getChatId({required String cid, required String otherId}) {
    var id = "";
    if (cid.compareTo(otherId) > 0) {
      id = "${cid}_$otherId";
    } else {
      id = "${otherId}_$cid";
    }

    FirebaseDatabase.instance.ref('messages').child(id).get().then((value) {
      if (value.exists) {

      }
      else {
        var chatId =
        FirebaseDatabase.instance.ref().child("messages").child(id).set(id);
        print(chatId);
      }
    });
    return id;
  }

  Future<String> uploadImageToStorage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images/${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask= storageRef.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }

  Future<File?> pickAndSendImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;

  }
}