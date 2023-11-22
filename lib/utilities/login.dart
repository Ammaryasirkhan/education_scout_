// ignore_for_file: use_build_context_synchronously

import 'package:education_scout_/Classes/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import '../Routes/controller.dart';
import '../Routes/routes.dart';
import '../home_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  bool isLoading = false;
  void login(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

    // Set loading state to true
    setState(() {
      isLoading = true;
    });

    // Create the request body
    Map<String, String> requestBody = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse(AppConstant.login),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Get the userRole from the response
        String userRole = jsonResponse['role'];
        print(userRole);

        // Set the user's role using the UserController
        final UserController userController = Get.find<UserController>();
        // userController.setUserRole(userRole);

        // Set the user as logged in
        userController.setLoggedIn(true);

        // Login successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Login successful',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              email: email,
            ),
          ),
        );
      } else if (response.statusCode == 401) {
        // Unauthorized: Invalid credentials
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Invalid email or password. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else if (response.statusCode == 402) {
        // Custom status code 402 (Payment Required) - Pending Status
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              'School is still in pending status.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else if (response.statusCode == 403) {
        // Forbidden: Rejected Status
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'School is in rejected status.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        // Handle other status codes as needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'An error occurred. Please try again later.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isValidEmail(String email) {
    // Define a regular expression pattern for a valid email address
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    String email = emailController.text;
    String password = passwordController.text;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pushNamed(context, MyRoutes.HomeRoute);
          },
        ),
      ),
      body: Stack(children: [
        Container(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         Colors.black12, Colors.black87
            //         // Color(0xFF33CCFF), // #33ccff

            //         // Color(0xFFFF99CC), // End color
            //       ],
            //       begin: Alignment.centerLeft,
            //       end: Alignment.centerRight,
            //     ),
            //   ),
            ),
        Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 70.0),
                Image.asset(
                  "images/a2.png",
                  fit: BoxFit.cover,
                  height: 200,
                ),
                Text(
                  " EXPLORE SCHOOLS TO GET BETTER DECISIONS",
                  style: GoogleFonts.oswald(fontSize: 14),
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType
                              .emailAddress, // Set the keyboardType to emailAddress
                          controller: emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Email',
                            labelStyle: const TextStyle(
                              color: Colors.black, // Label text color
                            ),
                            hintText: 'Enter your email address',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.black54,
                            ),
                            // Decoration details
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!isValidEmail(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10.0),
                        TextFormField(
                          obscureText: !_isPasswordVisible,
                          controller: passwordController,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: togglePasswordVisibility,
                              child: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              color: Colors.black, // Label text color
                            ),
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.black54),
                            // Decoration details
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                  minimumSize: const Size(50, 50)),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, MyRoutes.forgotten);
                              },
                              child: const Text(
                                "Forgotten password?",
                                // style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3.0),
                        Container(
                          width: 200,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      login(context);
                                    }
                                  },
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text(
                                    "Log In",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const Divider(
                          thickness: 1,
                          color: Colors.grey,
                          height: 50.0,
                        ),
                        const SizedBox(height: 5.0),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account yet?",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 2),
                                TextButton(
                                  child: const Text("Sign Up"),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, MyRoutes.ShowcaseRoute);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 88.0),
                        //   child: Text('@umw.edu.pk'),
                        // )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
