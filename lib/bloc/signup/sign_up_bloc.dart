import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:elml3b/repositories/userRepository.dart';
import 'package:elml3b/ui/validators.dart';
import 'package:meta/meta.dart';
import './bloc.dart';
// import 'package:rxdart/rxdart.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  UserRepository _userRepository;

  SignUpBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  SignUpState get initialState => SignUpState.empty();

  // @override
  // Stream<SignUpState> transformEvents(
  //   Stream<SignUpEvent> events,
  //   Stream<SignUpState> Function(SignUpEvent event) next,
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
  Stream<SignUpState> mapEventToState(
    SignUpEvent event,
  ) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is SignUpWithCredentialsPressed) {
      yield* _mapSignUpWithCredentialsPressedToState(
          email: event.email, password: event.password);
    }
  }

  Stream<SignUpState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<SignUpState> _mapPasswordChangedToState(String password) async* {
    yield state.update(isPasswordValid: Validators.isValidPassword(password));
  }

  Stream<SignUpState> _mapSignUpWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield SignUpState.loading();

    try {
      await _userRepository.signUpWithEmail(email, password);
      yield SignUpState.success();
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
      yield SignUpState.failure(errorMessage);
    }
  }
}
