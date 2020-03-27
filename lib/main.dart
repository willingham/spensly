import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spensly/theme.dart';
//import 'package:spensly/views/intro_screen.dart';
import 'package:spensly/views/onboarding_circle.dart';

import 'home.dart';
//import 'intro_screen.dart';


void main() => runApp(Spensly());

class Spensly extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spensly',
      theme: SpenslyTheme,
      home: MainController(),
    );
  }
}

class MainController extends StatefulWidget {
@override
MainControllerState createState() => new MainControllerState();
}

class MainControllerState extends State<MainController> {
Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (!_seen) {
      debugPrint('if here');
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Home()));
    } else {
      debugPrint('else here');
    prefs.setBool('seen', true);

    Navigator.of(context).pushReplacement(
        //MaterialPageRoute(builder: (context) => new IntroScreen()));
        MaterialPageRoute(builder: (context) => new OnBoardingCircle()));
        //MaterialPageRoute(builder: (context) => new OnBoarding()));

    }
}

@override
void initState() {
    super.initState();
    Timer(new Duration(milliseconds: 200), () {
    checkFirstSeen();
    });
}

@override
Widget build(BuildContext context) {
    
    return new Scaffold(
      body: Center(
          child: Text('FLoading...'),
      ),
    );
    
}
}
