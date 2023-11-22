import 'package:flutter/material.dart';

class MyStackWithContainers extends StatelessWidget {
  const MyStackWithContainers({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 25,
      color: Colors.amber,
      child: Container(
        width: 200,
        height: 150,
        child: Stack(
          children: [
            Positioned(
              left: 145,
              child: Container(
                color: Colors.red,
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Image.asset("images/a1.png"),
                ),
              ),
            ),
            Positioned(
              // bottom: 30,
              left: 35,
              right: 20,
              child: Card(
                elevation: 10,
                // height: 45,
                color: Colors.black.withOpacity(0.5),
                //padding: EdgeInsets.symmetric(vertical: 5),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Center(
                    //padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "Ammar yasir",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              // bottom: 30,
              left: 35,
              right: 20,
              child: Card(
                elevation: 10,
                // height: 45,
                color: Colors.black.withOpacity(0.5),
                //padding: EdgeInsets.symmetric(vertical: 5),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Center(
                    //padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "Class 7th",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
