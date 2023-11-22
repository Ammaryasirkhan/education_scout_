import 'package:education_scout_/Classes/ColoRar.dart';
import 'package:education_scout_/Routes/routes.dart';
import 'package:flutter/material.dart';

class YourRestrictedPage extends StatelessWidget {
  const YourRestrictedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
            ),
            Image.asset(
              'images/a3.png',
              fit: BoxFit.contain,
              height: 200,
              width: 200,
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    color: ColorRes.app,
                    size: 48.0,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Login Required',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, MyRoutes.login_page);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: ColorRes.app),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: ColorRes.app, // Set your desired color
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            // Add other content or instructions here
          ],
        ),
      ),
    );
  }
}
