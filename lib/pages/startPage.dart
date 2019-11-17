import 'package:flutter/material.dart';

import './loginSignupPage.dart';
import '../helpers/color_helper.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/startPageBG.jpg"),
                fit: BoxFit.fitHeight)),
        child: Stack(
          children: <Widget>[
            //  title text ====================================
            Positioned.fill(
              top: 80,
              child: Column(
                children: <Widget>[
                  Text(
                    "Welcome to",
                    style: TextStyle(fontSize: 50),
                  ),
                  Text("Neutral Creep",
                      style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          height: 0.7))
                ],
              ),
            ),

            //  Start button ====================================
            Align(
              alignment: Alignment(0, 0.8),
              child: ButtonTheme(
                height: 70,
                minWidth: 250,
                child: RaisedButton(
                  color: heidelbergRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35)),
                  child: Text(
                    "START",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),

                  //  Handle start button tapped ====================================
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => LoginSignUpPage()));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
