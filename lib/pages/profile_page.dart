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
                  CircleAvatar(
                    radius: 50,
                    child: ClipOval(
                      child: Image.network(
                        'https://media.istockphoto.com/id/1392528328/photo/portrait-of-smiling-handsome-man-in-white-t-shirt-standing-with-crossed-arms.jpg?s=612x612&w=0&k=20&c=6vUtfKvHhNsK9kdNWb7EJlksBDhBBok1bNjNRULsAYs=',
                        fit: BoxFit.fill,
                        height: 100,
                      ),
                    ),
                  ),
                  textField(nameController, const Icon(Icons.person), userProvider.currentUser?.name ?? 'Name'),
                  textField(emailController, const Icon(Icons.email), userProvider.currentUser?.email ?? 'Email'),
                  textField(numberController, const Icon(Icons.phone), '7783076220'),
                  ElevatedButton(
                    onPressed: () {
                      // Handle profile update logic here
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
