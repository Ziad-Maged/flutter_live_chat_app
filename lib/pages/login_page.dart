import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_live_chat_app/pages/home_page.dart';
import 'dart:async';
import 'dart:developer';

import 'package:flutter_live_chat_app/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _validateError = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: loginAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                    errorText: _validateError ? "Username is required" : null,
                    border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                            width: 1
                        )
                    ),
                    hintText: "Username"
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    errorText: _validateError ? "Password is required" : null,
                    border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                            width: 1
                        )
                    ),
                    hintText: "password"
                ),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40)
                ),
                child: const Text("Login"),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext context) => const RegistrationPage()
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40)
                ),
                child: const Text("Register"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async{
    setState(() {
      if(_usernameController.text.isEmpty || _passwordController.text.isEmpty){
        _validateError = true;
      }else {
        _validateError = false;
      }
    });
    if(_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty){
      try{
        List<Map<String, dynamic>> docs = (await FirebaseFirestore.instance.collection('users').get()).docs.map((e){
          Map<String, dynamic> temp = e.data();
          temp['id'] = e.id;
          return temp;
        }).toList();
        for (var element in docs) {
          if(element['username'] == _usernameController.text && element['password'] == _passwordController.text){
            log("Login Was Successful For ${element['id']}");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomePage(userInfo: element)
              )
            );
            return;
          }else {
            log("Login Failed. Incorrect Username Or Password");
          }
        }
      }catch(e){
        log("An Error Occured: $e");
      }
    }
  }

  AppBar loginAppBar(){
    return AppBar(
      title: const Text(
        "Login",
        style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
    );
  }
}