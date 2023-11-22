import 'package:education_scout_/Classes/ColoRar.dart';
import 'package:education_scout_/Routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../Classes/app_constant.dart';
import '../Classes/custom_container_class.dart';

class Myaccount extends StatefulWidget {
  final String email;

  const Myaccount({super.key, required this.email});

  @override
  _MyaccountState createState() => _MyaccountState();
}

class _MyaccountState extends State<Myaccount> {
  String username = '';
  String email = '';

  String userType = ''; // Add userType field
  String contact = ''; // Add contact field
  String address = ''; // Add address field
  List<Map<String, dynamic>> feedbackList = []; // Add feedbackList field

  // Update your fetchAccountInfo function to use the /combine route
  Future<void> fetchAccountInfo() async {
    final response = await http.get(
      Uri.parse('${AppConstant.combine}${widget.email}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userType = data['userType'];
        username = data['name'];
        email = data['email'];
        contact = data['contact'] ?? '';
        address = data['address'] ?? '';
        if (data.containsKey('feedback')) {
          feedbackList = List<Map<String, dynamic>>.from(data['feedback']);
        } else {
          feedbackList =
              []; // Default to an empty list if feedback is not available
        }
      });
    } else if (response.statusCode == 404) {
      // Handle "Account not found" case
      print('Account not found');
    } else {
      // Handle other error responses
      print('Failed to fetch account info');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAccountInfo();
  }

  Future<void> logout() async {
    // Perform logout tasks here
    Navigator.pushReplacementNamed(context, MyRoutes.login_page);
  }

  // Function to render user information based on userType
  Widget renderUserInfo() {
    if (userType == 'student') {
      return Column(
        children: [
          CustomInfoContainer(
            icon: Icons.person_2,
            text: 'Name: $username',
          ),
          SizedBox(
            height: 10,
          ),
          CustomInfoContainer(
            icon: Icons.email_outlined,
            text: 'Email: $email',
          )
        ],
      );
    } else if (userType == 'school') {
      return Column(
        children: [
          CustomInfoContainer(
            icon: Icons.person_2,
            text: 'Name: $username',
          ),
          SizedBox(
            height: 10,
          ),
          CustomInfoContainer(
            icon: Icons.email_outlined,
            text: 'Email: $email',
          ),
          const SizedBox(
            height: 10,
          ),
          CustomInfoContainer(
            icon: Icons.contact_page_outlined,
            text: 'Contact: $contact',
          ),
          const SizedBox(
            height: 10,
          ),
          CustomInfoContainer(
            icon: Icons.location_on_sharp,
            text: 'Address: $address',
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Review Feedbacks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        feedbackList.isEmpty
                            ? Center(
                                child: Text(
                                  "You have no feedbacks.",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: feedbackList.length,
                                  itemBuilder: (context, index) {
                                    final feedback = feedbackList[index];
                                    return ListTile(
                                      title: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.bubble_chart_outlined,
                                                color: ColorRes.app,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                feedback['Feedback_text'],
                                                style: GoogleFonts.roboto(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            color: ColorRes.app,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: ColorRes.app,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.feedback,
                      color: ColorRes.app,
                    ),
                    SizedBox(width: 16.0),
                    Text(
                      'Feedback',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Handle other user types or errors
      return Text('Unknown user type');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(userType);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              const Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('images/pn.png'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Personal Information',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              renderUserInfo(), // Call the function to render user information
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black45,
                      fixedSize: const Size(150, 30),
                    ),
                    onPressed: logout,
                    icon: Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
