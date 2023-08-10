import '/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'firebase_options.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent));
  // work only on potrait mode setting up
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp])
      .then((value) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initializeNotification();
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
        iconTheme: IconThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white, size: 28),
          backgroundColor: Color(0xFFd689ff),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

_initializeNotification() async {
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'To show message notification',
    id: 'Chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'ChatHub',
  );
  print(result);
}
