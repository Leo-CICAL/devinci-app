import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.teal,
  accentColor: Colors.tealAccent[200],
  textSelectionColor: Colors.tealAccent[700],
  textSelectionHandleColor: Colors.tealAccent[200],
  cursorColor: Colors.teal,
  backgroundColor: Color(0xff121212),
  scaffoldBackgroundColor: Color(0xff121212),
  cardColor: Color(0xff1E1E1E),
  indicatorColor: Colors.tealAccent[200],
  accentIconTheme: IconThemeData(color: Colors.white),
  unselectedWidgetColor: Colors.white,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.white,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.white,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.white,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.white,
    ),
  ),
);

ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.teal,
  primaryColor: Colors.teal,
  accentColor: Colors.teal[800],
  textSelectionColor: Colors.teal.withOpacity(0.4),
  textSelectionHandleColor: Colors.teal[800],
  cursorColor: Colors.teal,
  scaffoldBackgroundColor: Color(0xffFAFAFA),
  cardColor: Colors.white,
  indicatorColor: Colors.teal[800],
  accentIconTheme: IconThemeData(color: Colors.black),
  unselectedWidgetColor: Colors.black,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.black,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.black,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.black,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.black,
    ),
  ),
);

ThemeData trueDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.teal,
  accentColor: Colors.tealAccent[200],
  textSelectionColor: Colors.tealAccent[700],
  textSelectionHandleColor: Colors.tealAccent[200],
  cursorColor: Colors.teal,
  backgroundColor: Colors.black,
  scaffoldBackgroundColor: Colors.black,
  cardColor: Color(0xff121212),
  indicatorColor: Colors.tealAccent[200],
  accentIconTheme: IconThemeData(color: Colors.white),
  unselectedWidgetColor: Colors.white,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.white,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.white,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.white,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.white,
    ),
  ),
);
