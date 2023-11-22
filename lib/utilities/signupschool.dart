// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:education_scout_/Classes/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../Routes/routes.dart';

class signupschool extends StatefulWidget {
  const signupschool({Key? key}) : super(key: key);

  @override
  _signupschoolState createState() => _signupschoolState();
}

class _signupschoolState extends State<signupschool> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _registerSchool(String email, String name, String password,
      String phone, String address) async {
    // Validate email format
    List<int> documentBytes = await _document!.readAsBytes();
    List<int> imageBytes = await _image!.readAsBytes();
    String documentData = base64Encode(documentBytes);
    String imageData = base64Encode(imageBytes);
    // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    if (_formKey.currentState!.validate()) {
      if (!_validateEmail(email)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Email'),
            content: const Text('Make Sure! You Have Entered the valid email.'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
      if (name.length < 15 || name.length > 30) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Name'),
            content: const Text('Name should be between 15 and 30 characters.'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }

      // Validate password length
      if (password.length < 8 || password.length > 20) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Password'),
            content:
                const Text('Password should be between 8 and 20 characters.'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });

      const url =
          AppConstant.signupSchool; // Replace with your actual backend URL

      try {
        final response = await http.post(
          Uri.parse(url),
          body: {
            'email': email,
            'name': name,
            'password': password,
            'phone': phone,
            'address': address,
            'documentData': documentData,
            'imageData': imageData,
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Request Sent Successfully',
              style: TextStyle(color: Colors.white),
            ),
          ));
          await Future.delayed(const Duration(seconds: 5));
          Navigator.pushNamed(context, MyRoutes.login_page);
        } else if (response.statusCode == 400) {
          final message = jsonDecode(response.body)['message'];
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred. Please try again.'),
              actions: [
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error: $e'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isPasswordVisible = false;
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  bool _validateEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    return emailRegex.hasMatch(email);
  }

  File? _document;
  File? _image;
  Uint8List? _imageUnintList;
  Uint8List? _documentUnintList;
  // String? _documentPath;
  String? _imageName;
  String? _documentName;

  Future<void> _openDocumentPicker() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        if (kIsWeb) {
          if (result.files.single.bytes != null) {
            _documentUnintList = Uint8List.fromList(result.files.single.bytes!);
          }
        } else {
          _document = File(result.files.single.path!);
          _documentName = result.files.single.name;
        }
      });
    }
  }

  Future<void> _openImagePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      if (result.count == 1) {
        setState(() {
          if (kIsWeb) {
            if (result.files.single.bytes != null) {
              _imageUnintList = Uint8List.fromList(result.files.single.bytes!);
            }
          } else {
            if (result.files.single.path != null) {
              _image = File(result.files.single.path!);
            }
          }
          _imageName = result.files.single.name;
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select a single image file.'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Canceled'),
          content: const Text('File picking was canceled.'),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //color: Color.fromARGB(255, 192, 238, 238),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              title: const Text('SCHOOL'),
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
            const SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Institution name',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          hintText: 'Enter your name of institution',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the institution name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          hintText: 'Enter your email address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Mobile Number',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          hintText: 'Enter your mobile number',
                          prefixIcon: Icon(Icons.phone_android_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Address',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          hintText: 'Address',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0),
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
                          border: const OutlineInputBorder(),
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outlined),
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
                      const SizedBox(height: 8.0),
                      TextFormField(
                        // controller: confirmPasswordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Confirm Password',
                          suffixIcon: GestureDetector(
                            onTap: togglePasswordVisibility,
                            child: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          labelStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          hintText: 'Re-enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
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
                      const SizedBox(height: 15.0),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Column(
                                children: [
                                  const Text(
                                    "Upload License",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 8.0),
                                  SizedBox(
                                    width: 120,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _openDocumentPicker();
                                      },
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            const EdgeInsets.all(5)),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          Colors.transparent,
                                        ),
                                        side: MaterialStateProperty.all(
                                          BorderSide(
                                            width: 1.0,
                                            color:
                                                Colors.black.withOpacity(0.1),
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.upload_file),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "Upload",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_documentName != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Selected Document:",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _documentName!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: Center(
                              child: Column(
                                children: [
                                  const Text(
                                    "Upload Image",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 8.0),
                                  SizedBox(
                                    width: 120,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _openImagePicker();
                                      },
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            const EdgeInsets.all(5)),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          Colors.transparent,
                                        ),
                                        side: MaterialStateProperty.all(
                                          BorderSide(
                                            width: 1.0,
                                            color:
                                                Colors.black.withOpacity(0.1),
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.upload),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "Upload",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_imageName != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Selected Image:",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _imageName!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 0.6,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  // Set text color
                                  ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Next",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                final email = emailController.text;
                                final username = nameController.text;
                                final password = passwordController.text;
                                final phone = phoneController.text;
                                final address = addressController.text;
                                _registerSchool(
                                    email, username, password, phone, address);
                              },
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: _isLoading,
                        child: const CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
