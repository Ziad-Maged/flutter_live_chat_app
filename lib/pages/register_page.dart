import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _mobilePhoneController = TextEditingController();
  bool usernameError = false;
  bool passwordError = false;
  bool ageError = false;
  bool dateOfBirthError = false;
  bool mobilePhoneError = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: registrationAppBar(),
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
                  errorText: usernameError ? "Username is Required" : null,
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
                  errorText: passwordError ? "Password is Required" : null,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1
                    )
                  ),
                  hintText: "Password"
                ),
                obscureText: true,
              ),
              TextField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  errorText: dateOfBirthError ? "Date Of Birth Is Required" : null,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1
                    )
                  ),
                  hintText: "Date Of Birth",
                  prefixIcon: const Icon(Icons.calendar_today)
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  errorText: ageError ? "Age is Required" : null,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1
                    )
                  ),
                  hintText: "Age"
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _mobilePhoneController,
                decoration: InputDecoration(
                  errorText: mobilePhoneError ? "Mobile Phone Is Required" : null,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1
                    )
                  ),
                  hintText: "Mobile Phone"
                ),
                keyboardType: TextInputType.phone,
              ),
              ElevatedButton(
                onPressed: (){
                  register(
                    username: _usernameController.text,
                    password: _passwordController.text,
                    dateOfBirth: _dateOfBirthController.text,
                    age: _ageController.text,
                    mobilePhone: _mobilePhoneController.text
                  );
                  Navigator.of(context).pop();
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

  Future<void> register({
    required String username,
    required String password,
    required String dateOfBirth,
    required String age,
    required String mobilePhone
}) async{
    setState(() {
      usernameError = _usernameController.text.isEmpty;
      passwordError = _passwordController.text.isEmpty;
      dateOfBirthError = _dateOfBirthController.text.isEmpty;
      ageError = _ageController.text.isEmpty;
      mobilePhoneError = _mobilePhoneController.text.isEmpty;
    });
    if(usernameError || passwordError || dateOfBirthError || ageError || mobilePhoneError) {
      return;
    }
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    final jsonData = {
      'username': username,
      'password': password,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'mobilePhone': mobilePhone
    };
    await docUser.set(jsonData);
  }

  Future<void> _selectDate() async{
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030)
    );
    if(picked != null){
      setState(() {
        _dateOfBirthController.text = picked.toString().split(" ")[0];
      });
    }
  }

  AppBar registrationAppBar(){
    return AppBar(
      title: const Text(
        "Registration",
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
