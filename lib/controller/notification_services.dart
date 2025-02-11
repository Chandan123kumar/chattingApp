import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:bat_karo/pages/chat_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        criticalAlert: true,
        provisional: true,
        sound: true
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted Permission');
    }
    else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('user granted provisional permission');
    }
    else {
      AppSettings.openAppSettings();
      print('user denied permission');
    }
  }

  Future<String> getServerKey() async {
    var scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "fir-demo-project-57fd1",
          "private_key_id": "16160c568fd9f7ba91ad0f5aca3ea7c4fa1721f6",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQClJLizyziUbA89\naiJHi6EHkhodwWlYbBHF5Jrw7tDkjUtUB7MgZvmSsaAVXuKyt7t+0QKPfBqGP/RS\nKK34hdBPYCNEyXj+Sekqa4hQ7bXiIaVFooA+I+ci+JaPNKgA8bdtEGpZnJsCYVwo\nqjadKOKou5trZla1BRdhns/2s+tp9B2nZFYHN5w0D31nEKQTeU1jtl5/ePubprY4\nWkZmqTQrDNHoQdchQWdpfmzjf85o0xl1xh/erjmLBP2rBft7RwKzXLSegtyhmp5s\nY7l1hZnjMGn0sWfXDSzW8pphBEQL09eGBME2oGTor7tHFpMV9twyXwYzASnJRxGF\nD7/h5SV1AgMBAAECggEAGIZCCa1Jyzza7Ido7NAPC2VGjJmu78sovocq/VGx4uca\nwzFbiBnSwVawi8vqBZlkdjpK040eEUbJHTReVZRlsYv44Nu8pKLMRhjvBvmuM5VE\ninlN6yyAxEA/d6fdtTowP7ma2ZD4shtMSNuyPZeXRXCK7aGmib5mUQB5KM1iTfsO\nIScosEguv3SkCheSCfLKVHCbTNEk5hW5DwKEyoYlciFngz99jrRepSfoOG6z2J/j\naGiKw2R3gkY/bmNxr/eMWaBrdYGNreyLoC+xSfU8rwqrTTV3CaI9epUZO01CyEaq\nEwDR98b4adTyx6fRmHhUuKHv/uooIE4dQACtsYwzAQKBgQDJZ/ICSnBSd4QFe1dI\noc9I1SaB0iA0sHPLj5fPNuUjGTjSVMv8QW4cOtqBpdaxxjSsAgyp92//tR28Jdfb\nRiFY1ke/0i0wDvUGwfqIIneO8MUbtBpRi7fma86l+tbO3IQeXvP+EyrANJUNmsbY\n8toGU5sOaO4Cf5lJPO/kgYZT9QKBgQDR6G03GCXBt4K1n3rosab1kidxiAX+bTAt\nYqiPzj8x2Y4yqrMU7zcDwQggNRnNacv/aou6KbTOJGZWI4FFAjryrjpe8spMq6Ee\nmN8FOPKk0NixgyGfLPwM25LAHDLmf/WwnNe8nNbX6KLcyxWGEx85WfetbtLTrsic\nT+mFirIbgQKBgQClwd+iVQNGS8ii/lTimRFQ/uP3Oil5U7OpV994EdTZYxupt1I+\npNbrcuB8jTE6FEcrPXCQve02RShYvch+VaSCSbC5RVAdWmH8ks8PFVbSlIOUflCe\nxl+uyxFC90Os8j3mBP3IIJwxndUCYly/Fnerd0mIvYENG1jbtsQ0iwkztQKBgA76\nCnDX5DnCIi1bR6W6pzL2TqInFmZk2/8g/u3jxVaFM0QiMczYlJBMAYxqvYCOf+Ol\ncnrB5wieSD71IZAO7K3MCJYltJFr3X8VYTQ6L/XagNuJg6ibyRARypKycF9J2fnT\n9wCaICofix89zjdWve+Vn7pcIebAncepW/wPPU4BAoGBAK6kjvUtYXr+iv0SoGGF\nNd7VI1QfmkoBgZMzKQidpHmb9JE9pbhh9B6Hn5EcKLXf0k2WXkrnG24+DGF56YIn\nQVc/7SPb2fNzuYodrtQrViKxx+nYktlXLW6kAQCfv+I5ILMjIBLiPprFMURRBaxN\n4Fim9CXAUZmuFY58CiTMMG4G\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-1jc9a@fir-demo-project-57fd1.iam.gserviceaccount.com",
          "client_id": "100893037528515540262",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-1jc9a%40fir-demo-project-57fd1.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }
        ), scopes
    );
    final serverKey = client.credentials.accessToken.data;
    print("serverKey=$serverKey");
    return serverKey;
  }

  Future<void> initApp() async {
    AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);


    FirebaseMessaging.onMessage.listen((event) {
        print(event.notification);
        print(event.data);
    },);
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        message.notification!.android!.channelId.toString(),
        message.notification!.android!.channelId.toString(),
        importance: Importance.high,
        showBadge: true,
        playSound: true
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id,
        channel.name.toString(),
        channelDescription: 'Channel description',
        importance: Importance.max,
        priority: Priority.high,
        sound: channel.sound
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
        payload: message.data.toString()
    );
  }


  // void sendOrderNotification({required String message,required String token,required String senderName })async{
  //   print('token id :$token');
  //   final serverKey=await getServerKey();
  //   try{
  //     final response=await http.post(Uri.parse('https://fcm.googleapis.com/v1/projects/flutterfirebaseauth-439e4/messages:send'),
  //      headers: <String,String>{
  //       'Content-Type':'application/json',
  //        'Authorization':'Bearer $serverKey  '
  //      },
  //       body: jsonEncode(<String, dynamic>{
  //         "message":{
  //           "token":token,
  //           "data":{},
  //           "notification":{
  //             "title":senderName,
  //             "body":message
  //           }
  //         }
  //       })
  //     );
  //     if(response.statusCode==200){
  //     }else{
  //       print('failed to send notification,Status code:${response.statusCode}');
  //       Fluttertoast.showToast(msg: 'Failed to send notification');
  //     }
  //   }catch(ex){
  //     print('error sending notification: $ex');
  //     Fluttertoast.showToast(msg: 'error sending notification');
  //   }
  // }
  Future<void> sendOrderNotification({required String message, required String token, required String senderName,}) async {
    final serverKey = await getServerKey();
    const fcmUrl = "https://fcm.googleapis.com/v1/projects/fir-demo-project-57fd1/messages:send";

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Authorization': 'Bearer $serverKey',
          'Content-Type' : 'application/json'
        },
        body: json.encode({
          "message": {
            "token":token ,
            "notification": {
              "title": senderName,
              "body": message
            }
          }
        })
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully: ${response.body}');
        Fluttertoast.showToast(msg: ' notification send successfully');
      } else {
        print('Failed to send notification: ${response.statusCode} ${response
            .body}');
        Fluttertoast.showToast(msg: 'Failed to send notification');
      }
    } catch (e) {
      print('Error sending notification: $e');
      Fluttertoast.showToast(msg: 'Error sending notification');
    }
  }

  Future<void> handleMessage(RemoteMessage message) async {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) =>
          ChatPage(otherUid: message.data['senderName'],
              name: message.data['message'],
              email: message.data[''],
            profile: '',),));
    }
  }
  Future<void> sendCallNotification({required String callerID, required String token, required String callerName,}) async {
    final serverKey = await getServerKey();
    const fcmUrl = "https://fcm.googleapis.com/v1/projects/fir-demo-project-57fd1/messages:send";

    try {
      final response = await http.post(
          Uri.parse(fcmUrl),
          headers: {
            'Authorization': 'Bearer $serverKey',
            'Content-Type' : 'application/json'
          },
          body: json.encode({
            "message": {
              "token":token ,
              "notification": {
                "title": "$callerName is calling you",
                "body": "Tap to answer the call"
              },
              "data":{
                "call_id":callerID
              }
            }
          })
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully: ${response.body}');
        Fluttertoast.showToast(msg: ' notification send successfully');
      } else {
        print('Failed to send notification: ${response.statusCode} ${response
            .body}');
        Fluttertoast.showToast(msg: 'Failed to send notification');
      }
    } catch (e) {
      print('Error sending notification: $e');
      Fluttertoast.showToast(msg: 'Error sending notification');
    }
  }


}


