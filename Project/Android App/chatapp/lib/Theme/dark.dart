import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  colorScheme:   const ColorScheme.dark(
    primary: Color(0xff252331)
  ),
  appBarTheme:  const AppBarTheme(
  centerTitle: true,
  elevation: 1,
  iconTheme: IconThemeData(color: Colors.white), // Change color for dark theme
  titleTextStyle: TextStyle(
    color: Colors.white, // Change color for dark theme
    fontWeight: FontWeight.normal,
    fontSize: 19,
  ),
  backgroundColor: Color(0xff252331), // Change background color for dark theme
),

);


