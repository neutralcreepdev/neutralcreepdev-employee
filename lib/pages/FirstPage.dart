import 'package:flutter/material.dart';
import 'dart:async';
import './LoginPage.dart';
class FirstPageWidget extends StatefulWidget {
  
  @override
  _FirstPageWidgetState createState() => _FirstPageWidgetState();
}

class _FirstPageWidgetState extends State<FirstPageWidget> {

  Timer _timer;

  int _start = 3;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => LoginPageWidget()));
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

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
              top: 600,
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