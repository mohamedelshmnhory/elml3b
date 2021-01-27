import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elml3b/repositories/fieldsRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'fields_event.dart';
part 'fields_state.dart';

class FieldsBloc extends Bloc<FieldsEvent, FieldsState> {
  FieldsRepository _fieldsRepository;

  FieldsBloc({@required FieldsRepository fieldsRepository})
      : assert(fieldsRepository != null),
        _fieldsRepository = fieldsRepository;

  @override
  FieldsState get initialState => LoadingState();

  @override
  Stream<FieldsState> mapEventToState(
    FieldsEvent event,
  ) async* {
    if (event is LoadListsEvent) {
      yield* _mapLoadListToState(currentUserId: event.userId);
    }
  }

  Stream<FieldsState> _mapLoadListToState({String currentUserId}) async* {
    yield LoadingState();
    Stream<QuerySnapshot> matchedList =
        _fieldsRepository.getMatchedList(currentUserId);
    yield LoadUserState(matchedList: matchedList);
  }
}
