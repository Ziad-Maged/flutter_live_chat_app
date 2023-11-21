import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_live_chat_app/pages/login_page.dart';

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