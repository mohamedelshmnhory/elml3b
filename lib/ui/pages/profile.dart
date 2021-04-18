import 'package:elml3b/bloc/profile/bloc.dart';
import 'package:elml3b/repositories/userRepository.dart';
import 'package:elml3b/ui/widgets/profileForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:move_to_background/move_to_background.dart';

import '../constants.dart';

class Profile extends StatelessWidget {
  final _userRepository;
  final userId;

  Profile({@required UserRepository userRepository, String userId})
      : assert(userRepository != null && userId != null),
        _userRepository = userRepository,
        userId = userId;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile Setup"),
          centerTitle: true,
          backgroundColor: backgroundColor,
          elevation: 0,
        ),
        body: BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(userRepository: _userRepository),
          child: ProfileForm(
            // userRepository: _userRepository,
          ),
        ),
      ),
    );
  }
}
