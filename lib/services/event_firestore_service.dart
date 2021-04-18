import 'package:elml3b/models/app_event.dart';
import 'package:firebase_helpers/firebase_helpers.dart';

final eventDBS = DatabaseService<AppEvent>(
  'events',
  fromDS: (id, data) => AppEvent.fromDS(id, data),
  toMap: (event) => event.toMap(),
);
