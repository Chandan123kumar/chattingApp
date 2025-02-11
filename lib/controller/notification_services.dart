import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:bat_karo/pages/chat_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

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
          "private_key_id": "7c200c860ed9a78898fcbaa819e46fb63244934b",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCtEpY2Ou5gdxDC\n3lNxHhYXteyoIm4kc9JWbXrUc1bakjcHqS/A/g8oFi4GwfUCZSSycBuwHsbK7Ueo\nA/eCkFjDYGVNHpH4qmaF//joXe8NS3k730U4xms9+BGVeKtfosLpnbb0iLWr+MJm\nYPMqyf7u/+twCS1x9iz7jzvtaDB4dzD4zsbi8OshmG+9KBUvVoAORNVZnh+j8YmW\nsyeRUeEt/fbXtRQOm/ukELi8dFIkvrYMcc+SJsDUmstorbTkDIM+Lg1u445sZp8h\nT89qNg0Pug8AVJk5YG8G5bRKU+RE/ef9BRWZpFgj8c4kJAuV3Yvrq8EAghKolSUl\nnn3ioS6tAgMBAAECggEAA9w5BPsiA31MXqhSUKDU6dD5NxPThJUfwSU+etwauRPP\nTeiwY7vW7zQ1cRmk4xmJ7L/y4iYBlZeexEjYXa1mCW+OOt7ebx8v27fGn7ouoYuI\nJ/V2KArG7BIrJDwViHPLKKZHpSMieDQ7c8igS9lHCiIjqHNP8+2DedXrRoOPJzSp\n52uJqbNWyrQpMwiRVn2Y/B8zUtRWsQr0jLfgYaNJnB+jJ8ExAKYn1klEqGc8gzig\nXLfLLGGbZQf+rjeXUcDnN082tJAW1dDTpYvlgNFWtsCiVVdTrLjRtV+cCx08dTed\n5S9L9kpvr43WnGmzuxu+zghEU2ghA0ZbK1yEXZ4vCQKBgQC5CJRJqwckx8nkiodA\n0UWVgw8IJINSPkoEca9iUfdaVyClT4l89V7OqnDXZ85vE+mi/Alk0aaByFTk6VH8\nj76buVQS8f3M1GllDSaSrmoGWwqEV18e3QhNafr7q4ISwb5MGPpUjMGJivk7xnce\nd6nOdUSd5IJid4Mar6Oo1C1btQKBgQDvc6HCT2yk2WYuhMMtlla19zDR4xIKwg4L\nRAavv1iOj4rTdJUQAwNiZpUTWEG51Ffte0yL0kWHT0fVYouRkI4CGhOjZgjuk10T\nIkukX+FMnItGMAB2+xpdj+bAX+Xm+X5fz7FpKYm2Yx0O11Z5IDhldB0Ut9S1EYaZ\n8aJwKA6SGQKBgDUtfQirCZONg72V/ocnXds5XlGVxNQXKMicL66PJgqlrbE06aur\nDUNSAro1kEOmMmhwDPcXtcXo4FUlpTVzznEM01fainmatmufWu2fCMOo2J3uSl0h\nYyh0g/heczSWz+0o5JD2Hw07jqOaR1PPSlMWqtDCAqLv/BLoVZ3I1PxdAoGAAoOE\nPzX2PgTKPdLG+cOKRX7C1HE9zz8aRqQALfgkRdrb6jxfFDvz3SSWjA1xIzJHegbB\nVvZuJG2Ao4zVSkHqO7tqWVzI2zhQ0dKaWK9o/hTmoWX/m0AnlrPcCEj5cONNoFPd\n2OzGtVN1CqLYFY1xCh+d7om/gecdMqCGxAanoIECgYEAi2/wacKHU+eHB5S/5N8V\nIvBS5V4jCWNehKvLdyktHqXq3evBwtQ6eqrzh4QlYl6cj+qhY79XrR/doosjX0C5\nWTSZdnq1SkNqsHcMiLkGcHGwVmcs0q0TxNH12RC79aVQoKiER+EWzJNjUUj+TYEO\nV9ywRPHD5kgmnqpsKp50kfk=\n-----END PRIVATE KEY-----\n",
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


