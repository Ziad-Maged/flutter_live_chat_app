import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_live_chat_app/pages/user_profile_page.dart';
import 'package:http/http.dart' as http;

class ChatRoomPage extends StatefulWidget {
  final Map<String, dynamic> frontUserInfo;
  final Map<String, dynamic> endUserInfo;
  final String chatRoomID;
  final List<Map<String, dynamic>> messages;
  final bool reverted;
  const ChatRoomPage({
    super.key,
    required this.frontUserInfo,
    required this.endUserInfo,
    required this.chatRoomID,
    required this.messages,
    required this.reverted
});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _textFormController = TextEditingController();
  late List<dynamic> messages;

  @override
  void initState(){
    messages = widget.messages;
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: chatRoomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          verticalDirection: VerticalDirection.up,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textFormController,
                    decoration: InputDecoration(
                      hintText: "message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide()
                      )
                    ),
                  ),
                ),
                const SizedBox(width: 5,),
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  radius: 20,
                  child: IconButton(
                    onPressed: sendText,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('chatroom').doc(widget.chatRoomID).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if(snapshot.hasError){
                    return const SizedBox(height: 40,);
                  }
                  if(!snapshot.hasData){
                    return const SizedBox(height: 40,);
                  }
                  Map<String, dynamic> docs = snapshot.data!.data() as Map<String, dynamic>;
                  messages = docs['messages'];
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> map = messages[index];
                      int isFront = map['senderID'].toString().toLowerCase().compareTo(widget.frontUserInfo['id'].toString().toLowerCase());
                      return Align(
                        alignment: (isFront == 0)? Alignment.topRight : Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                              color: (isFront == 0)? Colors.purple : Colors.grey,
                              borderRadius: (isFront == 0)?const BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                  topLeft: Radius.circular(30)
                              ):const BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                  topLeft: Radius.circular(30)
                              )
                          ),
                          margin: const EdgeInsets.only(
                              top: 10,
                              right: 10,
                              left: 10
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: (isFront == 0)?CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                map['body']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendText()async{
    if(_textFormController.text.isNotEmpty){
      Map<String, String> newMessage = {
        'senderID': widget.frontUserInfo['id'],
        'body': _textFormController.text,
        'sentAt': DateTime.now().toString()
      };
      setState(() {
        messages.add(newMessage);
      });
      await FirebaseFirestore.instance.collection('chatroom').doc(widget.chatRoomID).update({
        'messages': FieldValue.arrayUnion([newMessage])
      });
      final snap = await FirebaseFirestore.instance.collection('userTokens').doc(widget.frontUserInfo['username']).get();
      String token = snap['token'];
      sendPushMessage(token);
      log("Sent Note to $token");
      _textFormController.clear();
    }
  }

  void sendPushMessage(String token) async{
    try{
      final jsonData = {
        'body' : _textFormController.text,
        'deletedReceiver' : false,
        'deletedSender' : false,
        'receiverID' : widget.endUserInfo['username'],
        'senderID' : widget.frontUserInfo['username'],
        'title' : 'You received a message from ${widget.frontUserInfo['username']}'
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
              'body' : _textFormController.text,
              'title' : 'You received a message from ${widget.frontUserInfo['username']}'
            },
            'notification' : <String, dynamic>{
              'title' : 'You received a message from ${widget.frontUserInfo['username']}',
              'body' : _textFormController.text,
              'android_channel_id' : 'dbfood'
            },
            'to' : token
          }
        )
      );
      log("Pushed A Message");
      await FirebaseFirestore.instance.collection('notifications').doc().set(jsonData);
    }catch(error){
      log("Came Here With Error: $error");
    }
  }

  AppBar chatRoomAppBar(){
    return AppBar(
      title: Text(
        "${widget.endUserInfo['username']}",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black
        ),
      ),
      centerTitle: true,
      actions: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: IconButton(
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userInfo: widget.endUserInfo)
                )
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
        )
      ],
    );
  }
}
