import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:elml3b/repositories/userRepository.dart';
import 'package:elml3b/ui/validators.dart';
// import '/repositories/userRepository.dart';
// import 'package:chill/ui/validators.dart';
import 'package:meta/meta.dart';
import './bloc.dart';
// import 'package:rxdart/rxdart.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserRepository _userRepository;

  LoginBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  LoginState get initialState => LoginState.empty();

  // @override
  // Stream<LoginState> transformEvents(
  //   Stream<LoginEvent> events,
  //   Stream<LoginState> Function(LoginEvent event) next,
  // ) {
  //   final nonDebounceStream = events.where((event) {
  //     return (event is! EmailChanged || event is! PasswordChanged);
  //   });
  //
  //   final debounceStream = events.where((event) {
  //     return (event is EmailChanged || event is PasswordChanged);
  //   }).debounceTime(Duration(milliseconds: 300));
  //
  //   return super.transformEvents(
  //     nonDebounceStream.mergeWith([debounceStream]),
  //     next,
  //   );
  // }

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
          email: event.email, password: event.password);
    } else if (event is LoginWithGoogle) {
      yield* _mapLoginWithGoogleToState();
    }
  }

  Stream<LoginState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<LoginState> _mapPasswordChangedToState(String password) async* {
    yield state.update(isPasswordValid: Validators.isValidPassword(password));
  }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield LoginState.loading();
    try {
      await _userRepository.signInWithEmail(email, password);
      yield LoginState.success();
    } catch (error) {
      var errorMessage = 'Authentication failed';
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      print(error.code);
      yield LoginState.failure(errorMessage);
    }
  }

  Stream<LoginState> _mapLoginWithGoogleToState() async* {
    yield LoginState.loading();
    try {
      await _userRepository.signInGoogle();
      yield LoginState.success();
    } catch (error) {
      yield LoginState.failure(error);
    }
  }
}
