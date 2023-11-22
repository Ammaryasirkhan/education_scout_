import 'dart:convert';
import 'package:education_scout_/Classes/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PasswordResetPage extends StatefulWidget {
  final String email;

  const PasswordResetPage({Key? key, required this.email}) : super(key: key);

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  Future<void> resetPassword(
    String email,
    String verificationCode,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse(AppConstant.resetPassword),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': widget.email,
        'verificationCode': verificationCode,
        'newPassword': newPassword,
      }),
    );
    final form = _form.currentState;

    if (form != null && form.validate()) {
      // Form is valid, you can proceed with password reset
      // Your API call and response handling code here
    }
    if (response.statusCode == 200) {
      // Password updated successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset successful"),
        ),
      );
    } else if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid verification code. Please try again."),
        ),
      );
    } else if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Database error. Please try again later."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unknown error occurred. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.email);
    String email = widget.email;
    String verificationCode = "";
    String newPassword = "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: Container(
        child: Form(
          key: _form,
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              const Text(
                "Enter the verification code and set a new password",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  onChanged: (value) {
                    verificationCode = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    border: OutlineInputBorder(),
                    hintText: 'Enter the 5-letter code',
                  ),
                  maxLength: 5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    newPassword = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your new password',
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value!.length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    // You can add more validation here if needed
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                width: 250,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    resetPassword(email, verificationCode, newPassword);
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
