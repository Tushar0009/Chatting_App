import 'package:chat_hub/api/apis.dart';
import 'package:chat_hub/auth/loginScreen.dart';
import 'package:chat_hub/screens/homeScreen.dart';
import 'package:chat_hub/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

late Size  mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.white , systemNavigationBarColor: Colors.white)
      );
  // work only on potrait mode setting up
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp])
      .then((value) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
  mq = MediaQuery.of(context).size;
    return MaterialApp(
        title: 'Chat Hub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(color: Colors.black , size: 28),
                backgroundColor: Colors.white,
                elevation: 2,
            ),
        ),
        home:  const SplashScreen(),
        );
  }
}
