import 'package:flutter/material.dart';
import './pages/LoginPage.dart';
import './Helper/ColorHelper.dart';

void main() => runApp(MaterialApp(
  title: "Neutal Creep",
  debugShowCheckedModeBanner: false,
  home: LoginPageWidget(),theme: ThemeData(
  primaryColor: pink,
  accentColor: black,
  backgroundColor: white,
  canvasColor: grey,
  splashColor: blueGrey,
  cardColor: darkerGrey,
  cursorColor: maroon,
  fontFamily: "Air Americana",
),
));

