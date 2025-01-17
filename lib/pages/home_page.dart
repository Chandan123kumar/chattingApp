
import 'package:bat_karo/controller/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/user_controller.dart';
import 'chat_page.dart';

class ChatHomePage extends StatefulWidget {
  final String uid; // User ID
  const ChatHomePage({super.key, required this.uid});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  NotificationServices notificationServices=NotificationServices();

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPrmission();
    notificationServices.getDeviceToken();
    notificationServices.getServerKey();
    Future.microtask(() {
      Provider.of<UserProvider>(context, listen: false).fetchUserData(widget.uid);
    });
  }
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text("Bat_Karo",style: TextStyle(color: Colors.white),),
          actions: [
            IconButton(
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).logoutUser(context);
              },
              icon: const Icon(Icons.logout,color: Colors.white,),
            )
          ],
        ),
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoding) {
              return Center(child: CircularProgressIndicator());
            } else if (userProvider.userData.isEmpty) {
              return Center(child: Text("No users found"));
            } else {
              return ListView.builder(
                itemCount: userProvider.userData.length,
                itemBuilder: (context, index) {
                  var user = userProvider.userData[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>MassagePage(otherUid: user.id.toString(), name: user.name.toString(), email: user.email.toString(),),));
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading:  CircleAvatar(child: Icon(Icons.person),),
                        title: Text("${user.name}"),
                        subtitle: Text("${user.email}"),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        );
    }

}