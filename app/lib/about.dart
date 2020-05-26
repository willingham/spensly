import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
              child: GestureDetector(
                onTap: () => launchURL('https://spensly.com'),
                child: new Image.asset('assets/img/spensly-logo-transparent.png', fit: BoxFit.contain),
              )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 10, 50, 30),
              child: Text(
                'Spensly is a simple expense tracking and reimbursement request application, developed as an alternative to manually keeping up with and submitting expenses to an employer.',
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(100, 10, 100, 50),
              child: GestureDetector(
                onTap: () => launchURL('https://willinghamdigital.com'),
                child: new Image.asset('assets/img/wd-web-h.png', fit: BoxFit.contain),
              )
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Done'),
            ),
          ]
        )
      ),
    );
  }
}