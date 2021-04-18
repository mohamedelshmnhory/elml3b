part of 'fields_bloc.dart';

abstract class FieldsState extends Equatable {
  const FieldsState();
  @override
  List<Object> get props => [];
}

class LoadingState extends FieldsState {}

class LoadUserState extends FieldsState {
  final Stream<QuerySnapshot> matchedList;

  LoadUserState({this.matchedList});

  @override
  List<Object> get props => [matchedList];
}
