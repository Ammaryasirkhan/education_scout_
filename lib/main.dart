import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:education_scout_/Classes/gradient.dart';
import 'package:education_scout_/Routes/routes.dart';
import 'package:education_scout_/utilities/chatbox.dart';
import 'package:education_scout_/utilities/contactus.dart';
import 'package:education_scout_/utilities/newfeeds.dart';
import 'package:education_scout_/utilities/privacy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Admin/admin.dart';
import 'Routes/controller.dart';
import 'UserManual/boardin.dart';
import 'utilities/Forgotpassword/forgotten_password.dart';
import 'home_page.dart';
import 'utilities/login.dart';
import 'utilities/myaccount.dart';
import 'utilities/showcase.dart';
import 'utilities/signupschool.dart';
import 'utilities/signupstudent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final UserController userController = Get.put(UserController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: ThemeData(
            iconTheme: const IconThemeData(color: Colors.white),
            primarySwatch: const MaterialColor(
              0xFF667EE2,
              <int, Color>{
                50: Color.fromARGB(255, 140, 159, 231),
                100: Color.fromARGB(255, 15, 57, 224),
                200: Color(0xFF667EE2),
                300: Color(0xFF667EE2),
                400: Color(0xFF667EE2),
                500: Color.fromARGB(255, 18, 33, 94),
                600: Color(0xFF667EE2),
                700: Color.fromARGB(255, 61, 89, 199),
                800: Color(0xFF667EE2),
                900: Color.fromARGB(255, 14, 34, 114),
              },
            ),
            fontFamily: GoogleFonts.roboto().fontFamily),
        home: const SplashScreen(),
        routes: {
          MyRoutes.HomeRoute: (context) => const HomePage(
                email: 'your_email@example.com',
              ),
          MyRoutes.login_page: (context) => const Login(),
          MyRoutes.contact: (context) => const ContactUsPage(),
          MyRoutes.boardin: (context) => const BoardingPage(),
          MyRoutes.adminside: (context) => const Admin(),
          MyRoutes.ShowcaseRoute: (context) => const Showcase(),
          MyRoutes.signupschool: (context) => const signupschool(),
          MyRoutes.signupstudent: (context) => const signupstudent(),
          // MyRoutes.moreRoute: (context) => AdditionalInfoPage(),
          MyRoutes.forgotten: (context) => const ForgotPassword(),
          MyRoutes.privacy: (context) => const PrivacyPolicyPage(),

          MyRoutes.ChatboxRoute: (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            if (args != null && args is Map<String, dynamic>) {
              return Chatbox(email: args['email']);
            } else {
              // Handle the case when the argument is not provided or incorrect
              return const Chatbox(
                  email: ''); // Provide a default value if needed
            }
          },

          MyRoutes.MyaccountRoute: (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            if (args != null && args is Map<String, dynamic>) {
              return Myaccount(email: args['email']);
            } else {
              return const Myaccount(
                  email: ''); // Provide a default value if needed
            }
          },
          MyRoutes.NewfeedsRoute: (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            if (args != null && args is Map<String, dynamic>) {
              return Newfeeds(email: args['email']);
            } else {
              return const Newfeeds(
                  email: ''); // Provide a default value if needed
            }
          },
        });
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, MyRoutes.boardin);
    });

    return Scaffold(
        // backgroundColor: Colors.white, // Set background color
        body: Container(
      child: AnimatedSplashScreen(
        duration: 3000,
        backgroundColor: PurpleBlueGradientColor.white,
        splash: 'images/a2.png', // Your splash screen image
        nextScreen:
            const BoardingPage(), // The screen to navigate to after the animation
        splashTransition: SplashTransition.fadeTransition, // Animation type

        splashIconSize: 270, // Adjust as needed
      ),
    ));
  }
}
