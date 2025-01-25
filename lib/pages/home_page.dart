import 'package:bat_karo/controller/chat_provider.dart';
import 'package:bat_karo/controller/device_token_service.dart';
import 'package:bat_karo/controller/notification_services.dart';
import 'package:bat_karo/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  NotificationServices notificationServices = NotificationServices();
  DeviceTokenService deviceTokenService = DeviceTokenService();

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.getServerKey();
    deviceTokenService.storeDeviceToken();
    deviceTokenService.getDeviceTokenFromFirebase('');
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userProvider.getCurrentUser();
    Future.microtask(() {
      Provider.of<UserProvider>(context, listen: false)
          .fetchUserData(widget.uid);
    });

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    // getUserData();
    // 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          if (message.data['_id'] != null) {
            // Navigator.of(context).push(
            //   MaterialPageRoute(builder: (context) => Stays()),
            // );
          }
        }
      },
    );

    // 2. This method only call when App in foreground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          notificationServices.showNotification(message);
        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
        }
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatViewModel>(context);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          "Bat_Karo",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false)
                  .logoutUser(context);
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
          IconButton(
              onPressed: () {
                showItemMenuDialog(context);
                // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(),));
              },
              icon: Icon(Icons.more_vert))
        ],
      ),
        drawer:  Drawer(
          child: Column(
            children: [
              // User Account Header
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue, // Background color
                ),
                accountName: Text(
                  "",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  "johndoe@example.com", // Replace with userProvider.currentUser!.email.toString()
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    "J", // First letter of the user's name
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              // Navigation Menu List
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text("Home"),
                      onTap: () {
                        // Navigate to Home
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text("Profile"),
                      onTap: () {
                        // Navigate to Profile
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text("Settings"),
                      onTap: () {
                        // Navigate to Settings
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text("Logout"),
                      onTap: () {
                        // Handle logout
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            otherUid: user.id.toString(),
                            name: user.name.toString(),
                            email: user.email.toString(),
                          ),
                        ));
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
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

  void showItemMenuDialog(BuildContext context) {
    // List of menu items
    final List<String> menuItems = ["Profile", "Settings", "Share", "LogOut"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select an Option"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: menuItems.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(menuItems[index]),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    showSelectedOption(context,
                        menuItems[index]); // Display the selected option
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void showSelectedOption(BuildContext context, String selectedOption) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("You Selected"),
          content: Text(selectedOption),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
