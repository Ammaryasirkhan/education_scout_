import 'package:education_scout_/Classes/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Routes/routes.dart';

class signupstudent extends StatefulWidget {
  const signupstudent({Key? key}) : super(key: key);

  @override
  _signupstudentState createState() => _signupstudentState();
}

class _signupstudentState extends State<signupstudent> {
  bool _isLoading = false; // Add a loading state variable

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _registerStudent(
      String email, String name, String password) async {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      if (name.isEmpty || name.length > 30 || name.length < 10) {
        _showErrorDialog(
          'Invalid Username',
          'Username must be between 10 and 30 characters.',
        );
        return;
      }

      // Password length check
      if (password.length < 8 || password.length > 20) {
        _showErrorDialog(
          'Invalid Password',
          'Password should be between 8 and 20 characters.',
        );
        return;
      }
      // Set loading state to true
      setState(() {
        _isLoading = true;
      });

      const url = AppConstant.signupStudent;
      try {
        final response = await http.post(
          Uri.parse(url),
          body: {
            'email': email,
            'name': name,
            'password': password,
          },
        );

        if (response.statusCode == 200) {
          // Successful signup
          _showSuccessSnackbar();
          await Future.delayed(const Duration(seconds: 5));
          Navigator.pushNamed(context, MyRoutes.login_page);
        } else if (response.statusCode == 400) {
          // Email already exists
          final message = jsonDecode(response.body)['message'];
          _showErrorSnackbar(message);
        } else {
          _showErrorSnackbar('An error occurred. Please try again.');
        }
      } catch (e) {
        // Network or server error
        _showErrorSnackbar('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Signup Successful',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  bool _validateEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              title: const Text('STUDENT'),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 30.0),
            Image.asset(
              "images/a2.png",
              fit: BoxFit.cover,
              height: 200,
            ),
            const SizedBox(height: 5.0),
            const Text(
              "Welcome",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_3_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!_validateEmail(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: GestureDetector(
                          onTap: togglePasswordVisibility,
                          child: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password.';
                        } else if (!RegExp(
                                r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)")
                            .hasMatch(value)) {
                          return "Password should contain Capital, small letter & Number & Special";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: GestureDetector(
                          onTap: togglePasswordVisibility,
                          child: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    Container(
                      width: 400,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            // Set text color
                            ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                final email = emailController.text;
                                final username = nameController.text;
                                final password = passwordController.text;
                                _registerStudent(email, username, password);
                              },
                        child: const Text("Sign Up"),
                      ),
                    ),
                    Visibility(
                      visible: _isLoading,
                      child: const CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 30.0),
                    const Padding(
                      padding: EdgeInsets.only(right: 10.0, left: 10),
                      child: Center(
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.black54,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("OR", style: TextStyle(fontSize: 16)),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    InkWell(
                      onTap: () {
                        // Add your login with Google logic here
                      },
                      child: Container(
                        width: 400,
                        height: 45,
                        // padding: EdgeInsets.symmetric(
                        //     vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: const Color(0xFF667EE2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'images/icon.png', // Replace with your image path
                              width: 24, // Adjust the width as needed
                              height: 24, // Adjust the height as needed
                            ),
                            const SizedBox(width: 10),
                            const Center(
                              child: Text(
                                "Login with Google",
                                style: TextStyle(
                                  color: Colors.white,
                                  // fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
