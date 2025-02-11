import 'package:bat_karo/user_authentication/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [
              buildPage(
                  title: "Welcome to Bat_Karo",
                  description: "Connect with your friends easily",
                  lottie: "assets/animations/group.json"),
              buildPage(
                  title: "Fast & Secure",
                  description: "Your messages are encrypted and private",
                  lottie: "assets/animations/msg.json"),
              buildPage(
                  title: "Get Started Now",
                  description: "Sign up and start chatting today!",
                  lottie: "assets/animations/msg.json"),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: const WormEffect(dotHeight: 10, dotWidth: 10),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: TextButton(
              child: Text("Skip"),
              onPressed: () => _controller.jumpToPage(2),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              child: Text(isLastPage ? "Get Started" : "Next"),
              onPressed: () {
                if (isLastPage) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignupPage(),
                      ));
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage(
      {required String title,
      required String description,
      required String lottie}) {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            lottie, // Path to your animation file
            width: 250,
            height: 250,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 20),
          Text(title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(description,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
