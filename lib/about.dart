import 'package:flutter/material.dart';
import 'package:spensly/theme.dart';

class About extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          child: Container(
            child: Center(
              child: Text('Spensly')
            )
          )
        )
      ]
    );
  }
}