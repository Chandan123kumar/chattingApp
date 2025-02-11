import 'package:bat_karo/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'onboarding_screen.dart';

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
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {
      // Handle errors
    });
  }

  void _navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 5));
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatHomePage(uid: user.uid)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pinkAccent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/msgs.json', // Path to your animation file
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20), // Add spacing between animation and text
          const Center(
            child: Text(
              'Bat_Karo',
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
