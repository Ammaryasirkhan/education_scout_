import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'boardingclass.dart';
import 'package:education_scout_/Routes/routes.dart';

class BoardingPage extends StatefulWidget {
  const BoardingPage({super.key});

  @override
  State<BoardingPage> createState() => _BoardingPageState();
}

class _BoardingPageState extends State<BoardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667EE2).withOpacity(0.5),
                  Colors.blue.withOpacity(0.2)
                ],
              ),
            ),
          ),
          PageView.builder(
            controller: _controller,
            itemCount: 3, // Number of pages
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return InfoPage(
                imagePath: 'images/info${index + 1}.png',
                title: _getPageTitle(index),
                description: _getPageDescription(index),
              );
            },
          ),
          Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, MyRoutes.HomeRoute);
                  },
                  child: const Text("Skip"),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const WormEffect(),
                ),
                GestureDetector(
                  onTap: () {
                    _controller.nextPage(
                      curve: Curves.easeIn,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return '"Discover and Connect "';
      case 1:
        return '"Search for Schools"';
      case 2:
        return '"Advertise Your School"';
      default:
        return '';
    }
  }

  String _getPageDescription(int index) {
    switch (index) {
      case 0:
        return '"Explore a world of educational opportunities. Find the right schools for your needs or advertise your school to reach potential students and parents."';
      case 1:
        return '"Easily search and filter schools by location, curriculum, facilities, and more. Tailor your education journey for better future"';
      case 2:
        return '"Schools can showcase their offerings, facilities, and achievements to attract students and parents. Expand your reach."';
      default:
        return '';
    }
  }
}
