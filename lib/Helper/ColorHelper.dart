import 'package:flutter/material.dart';

Color parseColor(String color) {
  String hex = color.replaceAll("#", "");
  if (hex.isEmpty) hex = "ffffff";
  if (hex.length == 3) {
    hex =
    '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
  }
  Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
  return col;
}

Color maroon = parseColor("8B041F");
Color blueGrey = parseColor("8E9AAF");
Color darkerGrey = parseColor("B3B3B3");
Color black = Colors.black;
Color white = Colors.white;
Color grey = parseColor("EFEFEF");
Color pink = parseColor("ED4856");