import 'package:elml3b/bloc/login/login_bloc.dart';
import 'package:elml3b/repositories/userRepository.dart';
import 'package:elml3b/ui/widgets/loginForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:move_to_background/move_to_background.dart';

class Login extends StatelessWidget {
  final UserRepository _userRepository;

  Login({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     "Welcome",
        //     style: TextStyle(fontSize: 36.0),
        //   ),
        //   centerTitle: true,
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        // ),
        body: BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(
            userRepository: _userRepository,
          ),
          child: LoginForm(
            userRepository: _userRepository,
          ),
        ),
      ),
    );
  }
}
