import 'package:elml3b/models/app_event.dart';
import 'package:elml3b/services/event_firestore_service.dart';
import 'package:elml3b/ui/pages/event_details.dart';
import 'package:elml3b/ui/widgets/pageTurn.dart';
import 'package:firebase_helpers/firebase_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class PlayerReservations extends StatelessWidget {
  final String userId;
  const PlayerReservations({this.userId});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder(
          stream: eventDBS.streamQueryList(args: [
            QueryArgsV2(
              "userId",
              isEqualTo: userId,
            ),
          ], orderBy: [
            OrderBy('date')
          ]),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              final events = snapshot.data;
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (BuildContext context, int index) {
                  AppEvent event = events[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.label,
                        color:
                            event.confirmed == true ? Colors.green : Colors.red,
                      ),
                      title: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              event.fieldName.length > 20
                                  ? '${event.fieldName.substring(0, 20)}...'
                                  : event.fieldName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${intl.DateFormat.yMd().format(event.date)}    \n',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('${intl.DateFormat('jm').format(event.start)}' +
                                  '\n' +
                                  '${intl.DateFormat('jm').format(event.end)}'),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => pageTurn(
                          EventDetails(event: event, userId: userId), context),
                    ),
                  );
                },
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
