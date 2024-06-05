import 'package:flutter/material.dart';


ThemeData light = ThemeData(
  brightness: Brightness.light,
  colorScheme:  const ColorScheme.light(
    background: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 1,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 19,
    ),
    backgroundColor: Colors.white,
  ),
);