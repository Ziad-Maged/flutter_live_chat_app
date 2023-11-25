import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SendNotificationsPage extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  const SendNotificationsPage({
    super.key,
    required this.userInfo
  });

  @override
  State<SendNotificationsPage> createState() => _SendNotificationsPageState();
}

class _SendNotificationsPageState extends State<SendNotificationsPage> {
  final _usernameController = TextEditingController();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool usernameError = false;
  bool titleError = false;
  bool bodyError = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: sendNotificationsPageAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: sendNotificationsPageBody(),
        ),
      ),
    );
  }

  Column sendNotificationsPageBody(){
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            errorText: (usernameError) ? "Username is required" : null,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(
                width: 1,
              )
            ),
            hintText: "Username"
          ),
        ),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            errorText: (titleError) ? "Title is required" : null,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(
                width: 1,
              )
            ),
            hintText: "Notification Title"
          ),
        ),
        TextField(
          controller: _bodyController,
          decoration: InputDecoration(
            errorText: (bodyError) ? "Body is required" : null,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(
                width: 1,
              )
            ),
            hintText: "Notification Body"
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () async{
            setState(() {
              if(_usernameController.text.isEmpty){
                usernameError = true;
                return;
              }else {
                usernameError = false;
              }
              if(_titleController.text.isEmpty){
                titleError = true;
                return;
              }else {
                titleError = false;
              }
              if(_bodyController.text.isEmpty){
                bodyError = true;
                return;
              }else {
                bodyError = false;
              }
            });
            final snap = await FirebaseFirestore.instance.collection('userTokens').doc(_usernameController.text).get();
            String token = snap['token'];
            final jsonData = {
              'body' : _bodyController.text,
              'deletedReceiver' : false,
              'deletedSender' : false,
              'receiverID' : _usernameController.text,
              'senderID' : widget.userInfo['username'],
              'title' : _titleController.text
            };
            await http.post(
                Uri.parse('https://fcm.googleapis.com/fcm/send'),
                headers: <String, String>{
                  'Content-Type' : 'application/json',
                  'Authorization' : 'key=AAAAHoVVHqU:APA91bF1yzbBbQzJYlpgP8XK5GwdINFYdE1iBm1mT9pLzphh53K2ihhQwkeJ3T6QcYi3tFYMJWXSUGOVnlolRpXRIgfkJbzrHTZAusghM1uKf_2Mm1wIjbTplcuFeAJfcyHrTw18D40I'
                },
                body: jsonEncode(
                    <String, dynamic>{
                      'priority' : 'high',
                      'data' : <String, dynamic>{
                        'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
                        'status' : 'done',
                        'body' : jsonData['body'],
                        'title' : jsonData['title']
                      },
                      'notification' : <String, dynamic>{
                        'title' : jsonData['title'],
                        'body' : jsonData['body'],
                      },
                      'to' : token
                    }
                )
            );
            await FirebaseFirestore.instance.collection('notifications').doc().set(jsonData);
            _usernameController.clear();
            _titleController.clear();
            _bodyController.clear();
          },
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40)
          ),
          child: const Text("Notify User"),
        ),
        const SizedBox(
          height: 30,
        ),
        const Center(
          child: Text(
            "Please Keep In Mind That This Page Is Not For Chatting, But For Notifying Other Users",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        )
      ],
    );
  }

  AppBar sendNotificationsPageAppBar(){
    return AppBar(
      title: const Text(
        "Send Notification",
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
    );
  }
}