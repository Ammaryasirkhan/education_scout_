import 'package:education_scout_/Routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Showcase extends StatelessWidget {
  const Showcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),

        //color: Color.fromARGB(255, 192, 238, 238),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 5.0,
                ),
                Image.asset(
                  "images/a2.png",
                  fit: BoxFit.cover,
                  height: 200,
                ),
                // ignore: prefer_const_constructors
                SizedBox(
                  height: 0.0,
                ),
                Text(
                  "SIGN UP AS A",
                  // style:GoogleFonts(),
                  style: GoogleFonts.roboto(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Container(
                        width: 200,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: ElevatedButton.icon(
                          icon: Image.asset(
                            "images/student.png",
                            width: 30,
                            height: 30,
                          ),
                          label: Text(
                            "STUDENT",
                            style: GoogleFonts.roboto(),
                          ),
                          style: ElevatedButton.styleFrom(
                              // Set text color
                              ),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, MyRoutes.signupstudent);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "OR",
                        style: GoogleFonts.robotoMono(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        width: 200,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: ElevatedButton.icon(
                          icon: Image.asset(
                            "images/school.png",
                            width: 30,
                            height: 30,
                          ),
                          label: Text(
                            "SCHOOL",
                            style: GoogleFonts.roboto(),
                          ),
                          style: ElevatedButton.styleFrom(
                              // Set text color
                              ),
                          onPressed: () {
                            Navigator.pushNamed(context, MyRoutes.signupschool);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.grey,
                        height: 50.0,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
