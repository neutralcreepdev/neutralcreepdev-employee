import 'package:flutter/material.dart';

import '../helpers/color_helper.dart';

class TopUpPage extends StatefulWidget {
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final _textController = TextEditingController();
  var _value = "1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: alablaster,
        centerTitle: true,
        elevation: 0.2,
        iconTheme: IconThemeData(color: heidelbergRed, size: 30),
        title: Text(
          "Top-Up",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
              letterSpacing: 3),
        ),
      ),
      backgroundColor: whiteSmoke,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Enter top-up amount"),
            Container(
              width: MediaQuery.of(context).size.width - 100,
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 50),
            Text("credit Card:"),
            Container(
              height: 200,
              width: MediaQuery.of(context).size.width - 70,
              decoration: BoxDecoration(
                  color: alablaster,
                  border: Border.all(width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 70,
              child: DropdownButton(
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: "1",
                      child: Text("item 1"),
                    ),
                    DropdownMenuItem(
                      value: "2",
                      child: Text("item 2"),
                    )
                  ],
                  onChanged: (value) {
                    setState(() {
                      _value = value;
                    });
                  },
                  value: _value),
            ),
            SizedBox(height: 30),
            ButtonTheme(
              height: 60,
              minWidth: 300,
              child: RaisedButton(
                color: heidelbergRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35)),
                child: Text(
                  "Confirm",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
