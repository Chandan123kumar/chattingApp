import 'package:bat_karo/controller/chat_provider.dart';
import 'package:bat_karo/controller/device_token_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../controller/user_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  ChatViewModel chatViewModel = ChatViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.getCurrentUser().then((_) {
        if (userProvider.currentUser != null) {
          nameController.text = userProvider.currentUser!.name!;
          emailController.text = userProvider.currentUser!.email!;
          numberController.text = '7783076220'; // Placeholder for phone number
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        centerTitle: true,
      ),
      body: userProvider.currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[500],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {},
                          child: CircleAvatar(
                            radius: 50,
                            child: ClipOval(
                              child: Image.network(
                                userProvider.currentUser!.profilePicture
                                    .toString(),
                                fit: BoxFit.cover,
                                height: 100,
                                width: 100,
                              ),
                            ),
                    ),
                  ),
                  textField(nameController, const Icon(Icons.person), userProvider.currentUser?.name ?? 'Name'),
                  textField(emailController, const Icon(Icons.email), userProvider.currentUser?.email ?? 'Email'),
                  textField(numberController, const Icon(Icons.phone), '7783076220'),
                  ElevatedButton(
                    onPressed: () {
                            Navigator.pop(context);
                          },
                    child: const Text('Update Profile'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget textField(TextEditingController controller, Icon icon, String hint) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 60,
        child: Card(
          color: Colors.white,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: icon,
              hintText: hint,
            ),
          ),
        ),
      ),
    );
  }
}
