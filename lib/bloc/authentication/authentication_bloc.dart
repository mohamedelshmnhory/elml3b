import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:elml3b/repositories/userRepository.dart';
import 'package:flutter/cupertino.dart';

import './bloc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        try {
          final isSignedIn = await _userRepository.isSignedIn();
          if (isSignedIn) {
            final uid = await _userRepository.getUser();
            final isFirstTime = await _userRepository.isFirstTime(uid);
            if (!isFirstTime) {
              yield AuthenticatedButNotSet(uid);
            } else {
              final isManager = await _userRepository.isManager(uid);
              if (isManager)
                yield AuthenticatedManager(uid);
              else
                yield AuthenticatedPlayer(uid);
            }
          } else {
            yield Unauthenticated();
          }
        } catch (_) {
          yield Unauthenticated();
        }
      }
    } on SocketException catch (_) {
      print('not connected');
      yield Connection(false);
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    final isFirstTime =
        await _userRepository.isFirstTime(await _userRepository.getUser());

    if (!isFirstTime) {
      yield AuthenticatedButNotSet(await _userRepository.getUser());
    } else {
      final isManager =
          await _userRepository.isManager(await _userRepository.getUser());
      if (isManager)
        yield AuthenticatedManager(await _userRepository.getUser());
      else
        yield AuthenticatedPlayer(await _userRepository.getUser());
    }
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _userRepository.signOut();
  }
}
