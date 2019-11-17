import 'package:flutter/material.dart';

import '../helpers/color_helper.dart';

class ProfilePage extends StatefulWidget {
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: alablaster,
        centerTitle: true,
        elevation: 0.2,
        iconTheme: IconThemeData(color: heidelbergRed, size: 30),
        title: Text(
          "Profile",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
              letterSpacing: 3),
        ),
      ),
      body: Container(
        color: whiteSmoke,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[SizedBox(height: 30), Text("Account ID:")],
        ),
      ),
    );
  }
}
