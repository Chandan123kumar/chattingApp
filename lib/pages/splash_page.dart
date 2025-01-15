import 'package:bat_karo/controller/user_controller.dart';
import 'package:bat_karo/pages/home_page.dart';
import 'package:bat_karo/pages/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }

  void _navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 3));
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, navigate to ChatHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatHomePage(uid: user.uid)),
      );
    } else {
      // User is not logged in, navigate to SignupPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Bat_Karo',
              style: TextStyle(fontSize: 25, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
