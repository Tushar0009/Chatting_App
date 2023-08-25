import 'dart:io';
import 'package:chat_hub/auth/login_Items/backGroungIramges.dart';
import '/api/apis.dart';
import '/screens/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '/helper/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handleGoogleSignIn() {
    Dialogs.onProgress(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        print('user ${user.user}');
        print('user ${user.additionalUserInfo}');

        if (await APIS.userExists()) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          await APIS.newUser().then((value) => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              )));
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIS.auth.signInWithCredential(credential);
    } catch (e) {
      print('signing in with google $e');
      Dialogs.showSnakBar(context, 'Something went wrong (Check Internet)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        BackGroundImage(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.2,
                ),
                Container(
                    height: size.height * 0.1,
                    child: Center(
                        child: Text(
                      "Chat hub",
                      style: TextStyle(
                          fontSize: size.height * 0.085,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    ))),
                SizedBox(
                  height: size.height * 0.05,
                ),
                Container(
                  child: Text("Welcome back!",
                      style: TextStyle(
                          fontSize: size.height * 0.04,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Container(
                  height: size.height * 0.1,
                  child: Center(
                      child: Icon(
                    Icons.lock,
                    size: size.height * 0.09,
                  )),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                InkWell(
                    onTap: _handleGoogleSignIn,
                    child: Container(
                        width: size.width * 0.9,
                        height: size.height * 0.1,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            border: Border.all(
                                width: 2, color: Colors.grey.shade600),
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * 0.04,
                            ),
                            Image.asset('images/google.png',
                                height: size.height * 0.07),
                            SizedBox(
                              width: size.width * 0.05,
                            ),
                            Text(
                              "Continue with Google",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.height * 0.025),
                            )
                          ],
                        ))),
              ],
            ),
          ),
        )
      ],
    );
  }
}
