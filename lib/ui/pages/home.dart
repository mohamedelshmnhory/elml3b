import 'package:elml3b/bloc/authentication/authentication_bloc.dart';
import 'package:elml3b/bloc/authentication/authentication_state.dart';
import 'package:elml3b/repositories/userRepository.dart';
import 'package:elml3b/ui/pages/manager_screen.dart';
import 'package:elml3b/ui/pages/player_screen.dart';
import 'package:elml3b/ui/pages/profile.dart';
import 'package:elml3b/ui/pages/splash.dart';
import 'package:elml3b/ui/pages/splash_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login.dart';

class Home extends StatelessWidget {
  final UserRepository _userRepository;

  Home({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.teal),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Uninitialized) {
            return Splash();
          }
          if (state is Connection) {
            print('connection failed');
            return SplashError();
          }
          if (state is AuthenticatedButNotSet) {
            return Profile(
              userRepository: _userRepository,
              userId: state.userId,
            );
          }
          if (state is AuthenticatedPlayer) {
            return PlayerScreen(
              userId: state.userId,
            );
          }
          if (state is AuthenticatedManager) {
            return ManagerScreen(
              userId: state.userId,
            );
          }
          if (state is Unauthenticated) {
            return Login(
              userRepository: _userRepository,
            );
          } else
            return Container();
        },
      ),
    );
  }
}
