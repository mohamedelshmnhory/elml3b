part of 'fields_bloc.dart';

abstract class FieldsEvent extends Equatable {
  const FieldsEvent();
  @override
  List<Object> get props => [];
}

class LoadListsEvent extends FieldsEvent {
  final String userId;

  LoadListsEvent({this.userId});

  @override
  List<Object> get props => [userId];
}
