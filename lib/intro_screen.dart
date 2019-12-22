import 'package:flutter/material.dart';
import 'package:spensly/theme.dart';
import 'home.dart';

class IntroScreen extends StatelessWidget {
  _buildCircles(page, totalPages) {
    List<Widget> circles = [];
    for (var i=0; i<totalPages; i+=1) {
      bool longDot = i == page ;
      debugPrint("longDot: $longDot");
      circles.add(Padding(
        padding: EdgeInsets.all(5),
        child: Container(
        child: new Center(
          child: new Material(
            color: Colors.grey,
            type: MaterialType.button,
            child: new Container(
              width: longDot ? 40 : 20,
              height: 20,
              child: new InkWell(
              ),
            ),
          )
        )
        )
      )
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: circles,
    );
  }
  _buildPage(context, page, totalPages) {
    
    List<Widget> introPages = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container()
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(50, 0, 50, 20),
                  child: new Image.asset('assets/img/spensly-logo-horizontal.png', fit: BoxFit.contain)
                ),
                Text(
                'Welcome to Spensly,\nthe simple business expense tracker.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16.0,
                ),
              ),
              ]
            )
          ),
          Expanded(
            flex: 1,
            child: Container()
          ),
          Expanded(
            flex: 2,
            child: _buildCircles(page, totalPages)
          )
        ],
      ),
      Container(
        color: Colors.red[200],
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container()
            ),

            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(50, 20, 50, 10),
                    child: Text(
                      'Usage is simple:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                    child: Text('1. Add expenses with as much or little detail as you want.'),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                    child: Text('2. Use the send button to generate a report with all the expenses and images included.'),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(50, 10, 50, 0),
                    child: Text(
                      'That\'s it!',
                      style: TextStyle(
                        fontWeight: FontWeight.w700
                      )
                    ),
                  ),
                ]
              )
            ),
            Expanded(
              flex: 1,
              child: Container()
            ),
            Expanded(
              flex: 2,
              child: _buildCircles(page, totalPages)
            )

          ],
      )),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container()
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(50, 0, 50, 20),
                    child: new Image.asset('assets/img/spensly-logo-horizontal.png', fit: BoxFit.contain)
                  ),
                ]
              )
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RaisedButton(
                    color: Colors.red[200],
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                      )
                    ),
                    onPressed: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Home()));
                    },
                  )
                ]
              )
            ),
            Expanded(
              flex: 2,
              child: _buildCircles(page, totalPages)
            )

          ],
      ),
    ];
    if (page == null) {
      return introPages.length;
    } else {
      return introPages[page];
    }
  }
  int numPages() { return _buildPage(null, null, 0); }
  Widget buildPage(context, page) {
    return _buildPage(context, page, numPages());
  }

@override
Widget build(BuildContext context) {

    return new Scaffold(
      backgroundColor: SpenslyColors.green,
      body: PageView.builder(
        itemBuilder: (context, index) {
          return buildPage(context, index);
        },
        itemCount: numPages(),
      )
    );
}
}