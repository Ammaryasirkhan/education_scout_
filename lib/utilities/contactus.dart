import 'package:education_scout_/Classes/ColoRar.dart';
import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Contact Us'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get in Touch',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'If you have any questions or feedback, feel free to contact us using the information below:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email'),
                subtitle: Text('ammaryasirniazi567@gmail.com'),
              ),
              SizedBox(height: 6),
              Divider(
                color: ColorRes.app,
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Phone'),
                subtitle: Text('+91123456789'),
              ),
              SizedBox(height: 6),
              Divider(
                color: ColorRes.app,
              ),
              ListTile(
                leading: Icon(Icons.web),
                title: Text('Website'),
                subtitle: Text('https://banayenge.com'),
              ),
              SizedBox(height: 6),
              Divider(
                color: ColorRes.app,
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('LinkedIn'),
                subtitle: Text('Ammar Yasir'),
              ),
              SizedBox(height: 6),
              Divider(
                color: ColorRes.app,
              ),
              ListTile(
                leading: Icon(Icons.code),
                title: Text('GitHub'),
                subtitle: Text('Ammar YASIR'),
              ),
              SizedBox(height: 6),
              Divider(
                color: ColorRes.app,
              ),
              ListTile(
                leading: Icon(Icons.chat),
                title: Text('Twitter'),
                subtitle: Text('@AmmarYasir'),
              ),
              SizedBox(height: 6),
              Divider(
                color: ColorRes.app,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
