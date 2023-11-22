import 'package:education_scout_/Classes/app_constant.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class RejectedSchoolsScreen
    extends StatefulWidget {
  const RejectedSchoolsScreen({super.key});

  @override
  State<RejectedSchoolsScreen> createState() =>
      _RejectedSchoolsScreenState();
}

class _RejectedSchoolsScreenState
    extends State<RejectedSchoolsScreen> {
  List<String> rejectedSchools = [];

  @override
  void initState() {
    super.initState();
    fetchRejectedSchools();
  }

  Future<void> fetchRejectedSchools() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstant.getRejectedSchools),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(response.body);
        final List<String> schoolNames =
            data.cast<String>();

        setState(() {
          rejectedSchools = schoolNames;
        });
      } else {
        throw Exception(
            'Failed to fetch rejected schools');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejected Schools'),
      ),
      body: ListView.builder(
        itemCount: rejectedSchools.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0, vertical: 5),
            child: Card(
              elevation: 20,
              child: ListTile(
                title:
                    Text(rejectedSchools[index]),
                // Add more information or actions related to the school if needed
              ),
            ),
          );
        },
      ),
    );
  }
}
