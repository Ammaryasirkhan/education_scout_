import 'package:flutter/material.dart';
import '../Classes/ColoRar.dart';

class InfoPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const InfoPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //SizedBox(
          //   height: 150,
          // ),
          // Your image widget here
          Image.asset(
            imagePath,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ColorRes.app,
              fontSize: 26,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              height: 0,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
