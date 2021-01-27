import 'package:elml3b/bloc/authentication/authentication_bloc.dart';
import 'package:elml3b/bloc/authentication/authentication_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants.dart';

class SplashError extends StatefulWidget {
  @override
  _SplashErrorState createState() => _SplashErrorState();
}

class _SplashErrorState extends State<SplashError> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _showDialog(context));
  }

  _showDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                Text(
                  "error",
                  // style: TextStyle(color: Colors.red),
                ),
                SizedBox(
                  height: 30,
                ),
                Text("check your connection"),
                SizedBox(
                  height: 30,
                ),
                FlatButton(
                  child: Text(
                    "retry",
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  onPressed: () {
                    BlocProvider.of<AuthenticationBloc>(context)
                        .add(AppStarted());
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
