import 'package:education_scout_/Classes/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PendingSchoolsScreen
    extends StatefulWidget {
  const PendingSchoolsScreen({super.key});

  @override
  State<PendingSchoolsScreen> createState() =>
      _PendingSchoolsScreenState();
}

class _PendingSchoolsScreenState
    extends State<PendingSchoolsScreen> {
  List<String> pendingSchools = [];

  @override
  void initState() {
    super.initState();
    fetchPendingSchools();
  }

  Future<void> fetchPendingSchools() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstant.getPendingSchools),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(response.body);
        final List<String> schoolNames =
            data.cast<String>();

        setState(() {
          pendingSchools = schoolNames;
        });
      } else {
        throw Exception(
            'Failed to fetch pending schools');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void changeSchoolStatus(
      String schoolName, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:1000/updateSchoolStatus'),
        headers: {
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'schoolName': schoolName,
          'newStatus': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        // Status updated successfully, you can handle this as needed
        fetchPendingSchools(); // Refresh the list of pending schools
      } else {
        throw Exception(
            'Failed to update school status');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Schools'),
      ),
      body: ListView.builder(
        itemCount: pendingSchools.length,
        itemBuilder: (context, index) {
          final schoolName =
              pendingSchools[index];
          return Padding(
            padding: const EdgeInsets.only(
                right: 20.0, left: 20),
            child: GestureDetector(
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) =>
              //           PendingSchoolsDetails(),
              //     ),
              //   );
              // },
              child: Card(
                elevation: 10,
                child: ListTile(
                  title: Text(schoolName),
                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          // Change the school status to 'accepted'
                          changeSchoolStatus(
                              schoolName,
                              'accepted');
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Change the school status to 'rejected'
                          changeSchoolStatus(
                              schoolName,
                              'rejected');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
