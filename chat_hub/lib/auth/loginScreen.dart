import 'dart:io';

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
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: size.height * 0.73,
                decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: size.height * 0.1, left: size.width * 0.07),
                      child: Text("Login",
                          style: TextStyle(
                              fontSize: 45, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: size.height * 0.01, left: size.width * 0.07),
                        child: Text("Welcome",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w600))),
                    Padding(
                      padding: EdgeInsets.only(
                          top: size.height * 0.06,
                          left: size.width * 0.07,
                          right: size.width * 0.07),
                      child: Form(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return "Please enter the valid email address.";
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return "Password must be at least 6 characters long.";
                              }
                              return null;
                            },
                          ),
                          TextButton(
                              onPressed: () {},
                              child: Text(
                                "Forgot password ?",
                                style: TextStyle(color: Colors.white),
                              )),
                        ],
                      )),
                    ),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.07),
                      child: InkWell(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            height: size.height * 0.08,
                            width: size.width * 0.86,
                            child: Center(
                                child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            )),
                          )),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: size.height * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                        width: size.width * 0.2,
                        height: size.height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 2, color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20)),
                        child: IconButton(
                          onPressed: () {},
                          icon: Image.asset('images/facebook.png'),
                        )),
                    Container(
                        width: size.width * 0.2,
                        height: size.height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 2, color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20)),
                        child: IconButton(
                          onPressed: _handleGoogleSignIn,
                          icon: Image.asset('images/google.png'),
                        )),
                    Container(
                        width: size.width * 0.2,
                        height: size.height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 2, color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20)),
                        child: IconButton(
                          onPressed: () {},
                          icon: Image.asset('images/twitter.png'),
                        )),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
