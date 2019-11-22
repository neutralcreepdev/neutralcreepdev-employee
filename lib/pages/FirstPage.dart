
import 'package:flutter/material.dart';


class FirstPageWidget extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: -60,
              right: -31,
              child: Container(
                height: 333,
                child: Image.asset(
                  "assets/images/logo-neutralcreep2019-2.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 561,
              child: Text(
                "employee version",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                  letterSpacing: 1.2,
                  fontFamily: "Air Americana",
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}