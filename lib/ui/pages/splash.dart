import 'package:flutter/material.dart';

import '../constants.dart';

class Splash extends StatelessWidget {
  @override
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: backgroundColor,
      body: Container(
        width: size.width,
        child: Center(
          child: Text(
            "elml3b",
            style: TextStyle(
              color: backgroundColor,
              fontSize: size.width * 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
