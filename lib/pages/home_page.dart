import 'package:bat_karo/controller/chat_provider.dart';
import 'package:bat_karo/controller/device_token_service.dart';
import 'package:bat_karo/controller/notification_services.dart';
import 'package:bat_karo/model/user_model.dart';
import 'package:bat_karo/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
  String? userName;
  String? userEmail;
  String? profilePic;
  TextEditingController searchController = TextEditingController();
  List<UserModel> filterUsers = [];

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
    getUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserProvider userProvider = Provider.of<UserProvider>(
          context, listen: false);
      userProvider.fetchUserData(widget.uid).then((_) {
        setState(() {
          filterUsers =
              List.from(userProvider.userData); // Ensure list is populated
        });
      });
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

  void getUserData() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    var userRef = await FirebaseDatabase.instance.ref('user/${uid}').get();
    if (userRef.exists) {
      Map<String, dynamic> userData = Map<String, dynamic>.from(
          userRef.value as Map);
      setState(() {
        userName = userData['name'];
        userEmail = userData['email'];
        profilePic = userData['profilePicture'];
      });
    }
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
                showItemMenuDialog(context);
              },
              icon: Icon(Icons.more_vert))
        ],
      ),
        drawer:  Drawer(
          child: Column(
            children: [
              // User Account Header
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.pinkAccent, // Background color
                ),
                accountName: Text(
                  userName ?? 'Unknown Person',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  userEmail ?? 'unknown',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  maxRadius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(profilePic.toString()),
                ),
              ),

              // Navigation Menu List
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text("Profile"),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => const ProfilePage(),));
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
                        Provider.of<UserProvider>(context, listen: false)
                            .logoutUser(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share),
                      title: Text("Share"),
                      onTap: () async {
                        var text = await deviceTokenService
                            .generateDynamicLink();
                        Share.share(text.toString());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 18.0, vertical: 10),
              child: TextField(
                controller: searchController,
                onChanged: (query) {
                  filterUsersList(query, userProvider.userData);
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.isLoding) {
                  return const Center(child: CircularProgressIndicator());
                } else if (filterUsers.isEmpty) {
                  return const Center(child: Text("No users found"));
                } else {
                  return Expanded(child: ListView.builder(
                    itemCount: filterUsers.length,
                    itemBuilder: (context, index) {
                      var user = filterUsers[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatPage(
                                      otherUid: user.id.toString(),
                                      name: user.name.toString(),
                                      email: user.email.toString(),
                                      profile: user.profilePicture.toString(),
                                    ),
                              ));
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  user.profilePicture.toString()),
                            ),
                            title: Text("${user.name}"),
                            subtitle: Text("${user.email}"),
                          ),
                        ),
                      );
                    },
                  ));
                }
              },
            ),
          ],
        )


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

  void filterUsersList(String query, List<UserModel> users) {
    setState(() {
      if (query.isEmpty) {
        filterUsers = users;
      } else {
        filterUsers = users
            .where((user) =>
            user.name!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

}
