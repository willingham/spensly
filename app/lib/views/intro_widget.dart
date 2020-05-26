import 'package:flutter/material.dart';
import '../theme.dart';

class IntroWidget extends StatelessWidget {
  const IntroWidget(
      {Key key,
      @required this.screenWidth,
      @required this.screenheight,
      this.type,
      this.startGradientColor,
      this.endGradientColor,
      this.subText})
      : super(key: key);

  final double screenWidth;
  final double screenheight;
  final type;
  final Color startGradientColor;
  final Color endGradientColor;
  final String subText;

  @override
  Widget build(BuildContext context) {
    final Shader linearGradient = LinearGradient(
      colors: <Color>[startGradientColor, endGradientColor],
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    return Container(
      padding: EdgeInsets.only(top: 25),
      decoration: BoxDecoration(color: SpenslyColors.green),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Spacer(flex: 1),
          Expanded(
            flex: 1,
            child: Padding(
            child: Image.asset(
            'assets/img/spensly-logo-horizontal.png',
            fit: BoxFit.contain,
          ), padding: EdgeInsets.only(left: 50, right: 50),)),
          Spacer(flex: 1),
          Expanded(
            flex: 1,
            child: Container(
            padding: const EdgeInsets.only(left: 50),
            child: Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: <Widget>[
                Opacity(
                  opacity: 0.15,
                  child: Container(
                    height: screenheight * 0.15,
                    child: Text(
                      type.toString().toUpperCase(),
                      style: TextStyle(
                          fontSize: 100.0,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()..shader = linearGradient),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -5,
                  left: 15,
                  child: Text(
                    type.toString().toUpperCase(),
                    style: TextStyle(
                        fontSize: 62.0,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()..shader = linearGradient),
                  ),
                )
              ],
            ),
          )),
          Expanded(
            flex: 1,
            child: Container(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: Text(
              subText,
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.blueGrey,
                  letterSpacing: 2.0),
            ),
          )),
          Spacer(flex: 3)
        ],
      ),
    );
  }

  TextStyle buildTextStyle(double size) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: 0.5,
    );
  }
}