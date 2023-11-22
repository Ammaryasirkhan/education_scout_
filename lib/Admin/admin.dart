import 'package:education_scout_/Classes/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Routes/routes.dart';
import 'AcceptedSchoolsScreen.dart';
import 'PendingSchoolsScreen.dart';
import 'RejectedSchoolsScreen.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  Future<int> fetchStudentCount() async {
    final response = await http
        .get(Uri.parse(AppConstant.studentCount));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body);
      return data['studentCount'];
    } else {
      throw Exception(
          'Failed to load student count');
    }
  }

  Future<int> fetchSchoolCount() async {
    final response = await http
        .get(Uri.parse(AppConstant.schoolCount));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body);
      return data['schoolCount'];
    } else {
      throw Exception(
          'Failed to load school count');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF667EE2)
            .withOpacity(0.4),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.0),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF667EE2),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white,
                    // left: BorderSide(
                    //   color: Colors.white,
                    //   width: 3.0, // Set the border width as needed
                    // ),
                  ),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.logout),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                        color: Colors.white),
                  ),
                  onTap: () {
                    // Handle logout item tap
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 20.0, left: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white,
                    // left: BorderSide(
                    //   color: Colors.white,
                    //   width: 3.0, // Set the border width as needed
                    // ),
                  ),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.settings),
                  title: const Text(
                    'Setting',
                    style: TextStyle(
                        color: Colors.white),
                  ),
                  onTap: () {
                    // Handle logout item tap
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 20.0, left: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white,
                  ),
                ),
                child: ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text(
                    'Homepage',
                    style: TextStyle(
                        color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context,
                        MyRoutes.HomeRoute);
                    // Handle logout item tap
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 10.0,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  children: [
                    FutureBuilder<int>(
                      future: fetchStudentCount(),
                      builder:
                          (context, snapshot) {
                        if (snapshot
                                .connectionState ==
                            ConnectionState
                                .waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot
                            .hasError) {
                          return Text(
                              'Error: ${snapshot.error}');
                        } else {
                          return CardSection(
                            title: 'STUDENTS',
                            imagePath:
                                "images/student.png",
                            count: snapshot.data,
                          );
                        }
                      },
                    ),
                    FutureBuilder<int>(
                      future: fetchSchoolCount(),
                      builder:
                          (context, snapshot) {
                        if (snapshot
                                .connectionState ==
                            ConnectionState
                                .waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot
                            .hasError) {
                          return Text(
                              'Error: ${snapshot.error}');
                        } else {
                          return CardSection(
                            title: 'SCHOOLS',
                            imagePath:
                                "images/school.png",
                            count: snapshot.data,
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(
                    height:
                        20), // Add spacing between GridView and ListView
                ListView(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  children: const [
                    Hello(
                      name:
                          'PENDING LIST OF SCHOOLS',
                      icon: Icons.donut_large,
                    ),
                    Hello(
                      name:
                          'REJECTED LIST OF SCHOOLS',
                      icon: Icons.donut_large,
                    ),
                    Hello(
                      name:
                          'ACCEPTED LIST OF SCHOOLS',
                      icon: Icons.donut_large,
                    ),
                  ],
                ),
                const SizedBox(
                    height:
                        20), // Add spacing between GridView and ListView
                ListView(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  children: const [
                    Advertise(
                      name:
                          'Advertisement managment',
                      icon: Icons
                          .add_to_drive_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardSection extends StatelessWidget {
  final String title;
  final String imagePath;
  final count; // Add this property for the image path

  const CardSection({
    super.key,
    required this.title,
    required this.imagePath,
    required this.count, // Pass the image path when creating CardSection
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color:
          const Color.fromARGB(255, 138, 157, 235)
              .withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Image.asset(
              // Use Image.asset to display the image
              imagePath,
              height:
                  40, // Set the desired height
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Count: $count', // Display the count here
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Advertise extends StatelessWidget {
  final String name;
  final IconData icon;

  const Advertise({
    super.key,
    required this.name,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.pushNamed(context, MyRoutes.HomeRoute)
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadiusDirectional.circular(
                  40),
        ),
        child: Card(
          elevation: 2,
          color: const Color(0xFF667EE2)
              .withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Hello extends StatelessWidget {
  final String name;
  final IconData icon;

  const Hello({
    super.key,
    required this.name,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the respective screen when clicked
        if (name == 'PENDING LIST OF SCHOOLS') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const PendingSchoolsScreen()),
          );
        } else if (name ==
            'REJECTED LIST OF SCHOOLS') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const RejectedSchoolsScreen()),
          );
        } else if (name ==
            'ACCEPTED LIST OF SCHOOLS') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const AcceptedSchoolsScreen()),
          );
        }
      },
      child: Card(
        elevation: 4,
        color: const Color(0xFF667EE2)
            .withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
