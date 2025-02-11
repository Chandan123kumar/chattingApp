import 'package:bat_karo/audio_video_calling/audio_video_call_service.dart';
import 'package:bat_karo/controller/notification_services.dart';
import 'package:bat_karo/user_authentication/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/chat_provider.dart';
import 'controller/user_controller.dart';
import 'firebase_options.dart';
Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await Hive.initFlutter();
  // Hive.registerAdapter(UserModelAdapter());
  // await Hive.openBox<UserModel>('userBox');

  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  NotificationServices notificationServices=NotificationServices();
  notificationServices.initApp();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserProvider(),),
    ChangeNotifierProvider(create: (context) => ChatViewModel(),),
  ],child: MyApp(),));

}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
        debugShowCheckedModeBanner: false,
        home:SplashPage(),
        );
    }
}