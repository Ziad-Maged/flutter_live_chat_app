import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_live_chat_app/Helpers/HelperNotification.dart';
import 'package:flutter_live_chat_app/pages/login_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<dynamic> myBackgroundHandler(RemoteMessage remoteMessage) async{
  log("on Background Message: ${remoteMessage.notification?.title}/${remoteMessage.notification?.body}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid?
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAw_z7flLE0Ar8nq0xSxPPbpGVwW4R_TF0",
          appId: "1:131085967013:android:841f40998e9aaefce7374c",
          messagingSenderId: "131085967013",
          projectId: "flutter-live-chat-app"
        )
      )
  :await Firebase.initializeApp();

  try{
    final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
    await HelperNotification.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundHandler);
  }catch(error){
    //Ignored
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Chat App',
      theme: ThemeData(
        primarySwatch: Colors.green
      ),
      home: const LoginPage(),
    );
  }
}