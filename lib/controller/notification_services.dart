import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices{
  FirebaseMessaging messaging=FirebaseMessaging.instance;

  void requestNotificationPrmission()async{
    NotificationSettings settings= await messaging.requestPermission(
      alert: true,
      badge: true,
      carPlay: true,
      announcement: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print('User granted Permission');
    }
    else if (settings.authorizationStatus==AuthorizationStatus.provisional) {
      print('user granted provisional permission');
    } 
    else{
      AppSettings.openAppSettings();
      print('user denied permission');
    }
  }
}