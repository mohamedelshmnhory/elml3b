import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {}

class Connection extends AuthenticationState {
  final bool nice;
  Connection(this.nice);

  @override
  List<Object> get props => [nice];
}

class AuthenticatedManager extends AuthenticationState {
  final String userId;

  AuthenticatedManager(this.userId);

  @override
  List<Object> get props => [userId];

  @override
  String toString() => "Authenticated {userId}";
}

class AuthenticatedPlayer extends AuthenticationState {
  final String userId;

  AuthenticatedPlayer(this.userId);

  @override
  List<Object> get props => [userId];

  @override
  String toString() => "Authenticated {userId}";
}

class AuthenticatedButNotSet extends AuthenticationState {
  final String userId;

  AuthenticatedButNotSet(this.userId);

  @override
  List<Object> get props => [userId];
}

class Unauthenticated extends AuthenticationState {}
