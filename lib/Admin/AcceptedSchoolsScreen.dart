import 'package:education_scout_/Classes/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // Import the 'dart:math' library

// Define a list of random colors
final List<Color> randomColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
  // Add more colors as needed
];

class AcceptedSchoolsScreen
    extends StatefulWidget {
  const AcceptedSchoolsScreen({super.key});

  @override
  State<AcceptedSchoolsScreen> createState() =>
      _AcceptedSchoolsScreenState();
}

class _AcceptedSchoolsScreenState
    extends State<AcceptedSchoolsScreen> {
  List<String> acceptedSchools = [];

  @override
  void initState() {
    super.initState();
    fetchAcceptedSchools();
  }

  Future<void> fetchAcceptedSchools() async {
    try {
      final response = await http.get(Uri.parse(
          AppConstant.getApprovedSchools));

      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(response.body);
        final List<String> schoolNames =
            data.cast<String>();

        setState(() {
          acceptedSchools = schoolNames;
        });
      } else {
        throw Exception(
            'Failed to fetch accepted schools');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // Function to generate a random color from the list
  Color getRandomColor() {
    final random = Random();
    return randomColors[
        random.nextInt(randomColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accepted Schools'),
      ),
      body: ListView.builder(
        itemCount: acceptedSchools.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0, vertical: 5),
            child: Card(
              elevation: 20,
              child: ListTile(
                title:
                    Text(acceptedSchools[index]),
                // Add more information or actions related to the school if needed
              ),
            ),
          );
        },
      ),
    );
  }
}
