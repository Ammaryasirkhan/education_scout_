import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Classes/ColoRar.dart';

class CustomInfoContainer extends StatelessWidget {
  final IconData icon;
  final String text;

  CustomInfoContainer({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorRes.app,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
      ),
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: ColorRes.app,
              ),
              SizedBox(width: 16.0), // Add spacing between icon and text
              Text(
                text,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
