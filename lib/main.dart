import 'package:flutter/material.dart';
import 'package:spensly/about.dart';
import 'package:spensly/expenses.dart';
import 'package:spensly/submission_helpers.dart';
import 'package:spensly/theme.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spensly',
      theme: SpenslyTheme,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _changed = 0;

  stateChanged() {
    // Increment _changed everytime ui needs to be refreshed.
    setState(() {
      _changed += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.all(54),
          child: new Image.asset('assets/img/spensly-logo-horizontal.png', fit: BoxFit.contain),
        ),
        actions: [
          IconButton(icon: Icon(Icons.send), onPressed: () async {
            sendEmail(context, stateChanged);
          },)
        ]
      ),
      drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: new Image.asset('assets/img/spensly-logo-profile.png', fit: BoxFit.contain),
            decoration: BoxDecoration(
              color: SpenslyColors.green,
            ),
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.of(context).pop();
              Navigator.of(context, rootNavigator: true).push(
               MaterialPageRoute<bool>(
                fullscreenDialog: true,
                builder: (BuildContext context) => new About(),
              ),
            );
            },
          ),
        ],
      ),
    ),
      body: Spensly(key: Key(_changed.toString())),
    );
  }
}
