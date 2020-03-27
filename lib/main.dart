import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spensly/theme.dart';
import 'package:spensly/views/onboarding_circle.dart';

import 'home.dart';

void main() => runApp(Spensly());

class Spensly extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spensly',
      theme: SpenslyTheme,
      home: MainController(),
    );
  }
}

class MainController extends StatelessWidget {
  Future checkFirstSeen(context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool _seen = (prefs.getBool('seen') ?? false);

      if (_seen) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()));
      } else {
        prefs.setBool('seen', true);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => new OnBoardingCircle()));
      }
  }

  @override
  Widget build(BuildContext context) {
    checkFirstSeen(context);
      return new Scaffold(
        body: Container(),
      );
      
  }
}
