import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userInfo;
  const ProfilePage({
    super.key,
    required this.userInfo
});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profilePageAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              "Mobile Phone: ${userInfo['mobilePhone']}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20,),
            Text(
              "Age: ${userInfo['age']}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20,),
            Text(
              "Date Of Birth: ${userInfo['dateOfBirth']}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar profilePageAppBar(){
    return AppBar(
      title: Text(
        userInfo['username'],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black
        ),
      ),
      centerTitle: true,
    );
  }

}
