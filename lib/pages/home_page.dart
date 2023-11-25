import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_live_chat_app/pages/chat_room.dart';
import 'package:flutter_live_chat_app/pages/send_notification_page.dart';
import 'package:flutter_live_chat_app/pages/view_notification_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  const HomePage({
    super.key,
    required this.userInfo
});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homePageAppBar(),
      endDrawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(""),
            ),
            ListTile(
              title: const Text("View All Notifications"),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ViewNotificationsPage(userInfo: widget.userInfo)
                  )
                );
              },
            ),
            ListTile(
              title: const Text("Push Notifications To User"),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => SendNotificationsPage(
                        userInfo: widget.userInfo,
                      )
                  )
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getUsers(),
        builder: (context, snapshot){
          if(snapshot.hasError){
            return Text("Something Went Wrong! ${snapshot.error}");
          }else if(snapshot.hasData){
            final users = snapshot.data;
            return ListView(
              children: users!.map(checkUser).toList(),
            );
          }else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget checkUser(Map<String, dynamic> user) {
    if(user['id'] != widget.userInfo['id']) {
      return ListTile(
        leading: CircleAvatar(
          child: Text("${user['age']}"),
        ),
        title: Text("${user['username']}"),
        onTap: () async {
          try{
            List<Map<String, dynamic>> docs = (await FirebaseFirestore.instance.collection('chatroom').get()).docs.map((e){
            Map<String, dynamic> temp = e.data();
            temp['id'] = e.id;
            return temp;
            }).toList();
            bool isPresent = false;
            String roomID = "";
            List<Map<String, dynamic>> chatMessages = [];
            bool reverted = false;
            for(var e in docs){
              if((e['frontUserID'] == widget.userInfo['id'] && e['endUserID'] == user['id']) || (e['endUserID'] == widget.userInfo['id'] && e['frontUserID'] == user['id'])){
                isPresent = true;
                reverted = (e['endUserID'].toString().toLowerCase() == widget.userInfo['id'].toString().toLowerCase() && e['frontUserID'].toString().toLowerCase() == user['id'].toString().toLowerCase());
                roomID = e['id'];
                log("Messages: ${e['messages']}");
                chatMessages = List<Map<String, dynamic>>.from(e['messages']);
                break;
              }
            }
            if(!isPresent){
              final docChatRoom = FirebaseFirestore.instance.collection('chatroom').doc();
              final json = {
                'frontUserID': widget.userInfo['id'],
                'endUserID': user['id'],
                'messages': <Map<String, dynamic>>[]
              };
              await docChatRoom.set(json);
              roomID = docChatRoom.id.toString();
              chatMessages = <Map<String, dynamic>>[];
            }
            log("Entering Chatroom");
            if(!reverted){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatRoomPage(
                    frontUserInfo: widget.userInfo,
                    endUserInfo: user,
                    chatRoomID: roomID,
                    messages: chatMessages,
                    reverted: false,
                  )
                )
              );
            }else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatRoomPage(
                    frontUserInfo: widget.userInfo,
                    endUserInfo: user,
                    chatRoomID: roomID,
                    messages: chatMessages,
                    reverted: true,
                  )
                )
              );
            }
          }catch(e) {
            log("Came Here with Error: $e");
          }
        },
      );
    }else {
      return const SizedBox(height: 3,);
    }
  }

  Stream<List<Map<String, dynamic>>> getUsers() => FirebaseFirestore.instance.collection('users').snapshots().map((event) => event.docs.map((e) {
    Map<String, dynamic> temp = e.data();
    temp['id'] = e.id;
    return temp;
  }).toList());

  AppBar homePageAppBar(){
    return AppBar(
      title: const Text(
        "Home Page",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black
        ),
      ),
      centerTitle: true,
    );
  }
}
