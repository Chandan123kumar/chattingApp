import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controller/user_controller.dart';
import 'login_page.dart';
import 'dart:io';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfileImage(String uId) async {
    if (_profileImage == null) return;

    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_pictures/$uId.jpg');
      await storageRef.putFile(_profileImage!);

      final downloadUrl = await storageRef.getDownloadURL();
      final databaseRef = FirebaseDatabase.instance.ref().child('user/$uId');
      await databaseRef.update({
        'profilePicture': downloadUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload profile picture: $e")),
      );
    }
  }

  _signUpAndUploadImage(UserProvider provider) async {
    try {
      await provider.userSignUp(context);
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await _uploadProfileImage(user.uid);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during signup: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var provider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Background container
          Container(
            color: Colors.black,
            alignment: Alignment.topLeft,
          ),
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        "SignUP",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(75),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withOpacity(0.2),
                                spreadRadius: 10,
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 75,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 50,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: provider.nameController,
                      decoration: InputDecoration(
                        hintText: "Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: provider.emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: provider.passwordController,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              _signUpAndUploadImage(provider);
                            },
                            child: const Text("Sign Up"),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text("Already have an account?"),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 10, top: 80),
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
