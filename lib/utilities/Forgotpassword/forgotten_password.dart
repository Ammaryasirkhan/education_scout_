import 'dart:convert';
import 'package:education_scout_/utilities/Forgotpassword/password_reset_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Classes/app_constant.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  Future<void> sendVerificationCode(String email, BuildContext context) async {
    final response = await http.post(
      Uri.parse(AppConstant.sendcode),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PasswordResetPage(email: '${email}'),
      ));
    } else if (response.statusCode == 400) {
    } else if (response.statusCode == 500) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.body),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String email = "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Image.asset(
              "images/a2.png",
              fit: BoxFit.cover,
              height: 150,
            ),
            const SizedBox(height: 10.0),
            const Text(
              "Provide your email to verify your identity",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
            ),
            const SizedBox(height: 15.0),
            Container(
              width: 250,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  sendVerificationCode(email, context);
                },
                child: const Text("Send verification code"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
