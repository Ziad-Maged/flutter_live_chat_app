import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewNotificationsPage extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  const ViewNotificationsPage({
    super.key,
    required this.userInfo
});

  @override
  State<ViewNotificationsPage> createState() => _ViewNotificationsPageState();
}

class _ViewNotificationsPageState extends State<ViewNotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: viewNotificationsAppBar(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getNotifications(),
        builder: (context, snapshot){
          if(snapshot.hasError){
            return const Text("Something went Wrong");
          }else if(snapshot.hasData){
            final notifications = snapshot.data;
            final rows = [Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(12.0),
                    ),
                    child: const Text("Delete All"),
                  ),
                )
              ],
            )];
            final validNotifications = notifications!.map((e) {
              if((e['senderID'] == widget.userInfo['username'] && !e['deletedSender']) || (e['receiverID'] == widget.userInfo['username'] && !e['deletedReceiver'])){
                return Row(
                  children: [
                    Text(
                      "Title: ${e['title']}\n Body: ${e['body']}",
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.redAccent,
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: (){},
                      ),
                    )
                  ],
                );
              }else {
                return const Row();
              }
            });
            rows.addAll(validNotifications);
            return ListView(
              children: rows,
            );
          }
          return const Center(
            child: Text(
              "No Notifications yet",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 32
              ),
            ),
          );
        },
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> getNotifications() => FirebaseFirestore.instance.collection('notifications').snapshots().map((event) => event.docs.map((e){
    Map<String, dynamic> temp = e.data();
    temp['id'] = e.id;
    return temp;
  }).toList());

  AppBar viewNotificationsAppBar(){
    return AppBar(
      title: const Text(
        "View Notifications",
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
