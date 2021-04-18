import 'package:elml3b/models/app_event.dart';
import 'package:elml3b/models/user.dart';
import 'package:elml3b/services/event_firestore_service.dart';
import 'package:elml3b/ui/constants.dart';
import 'package:elml3b/ui/pages/add_event.dart';
import 'package:elml3b/ui/pages/event_details.dart';
import 'package:elml3b/ui/widgets/pageTurn.dart';
import 'package:firebase_helpers/firebase_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class FieldTable extends StatefulWidget {
  final User currentUser, selectedUser;
  const FieldTable({this.currentUser, this.selectedUser});
  @override
  _FieldTableState createState() => _FieldTableState();
}

class _FieldTableState extends State<FieldTable> {
  CalendarController _calendarController = CalendarController();
  Map<DateTime, List<AppEvent>> _groupedEvents;
  // DateTime initialDate;
  var _selectedEvents;
  DateTime selectedDate;
  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  _groupEvents(List<AppEvent> events) {
    _groupedEvents = {};
    events.forEach((event) {
      DateTime date =
          DateTime.utc(event.date.year, event.date.month, event.date.day, 12);
      if (_groupedEvents[date] == null) _groupedEvents[date] = [];
      _groupedEvents[date].add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: ,
      appBar: widget.currentUser.uid == widget.selectedUser.uid
          ? null
          : AppBar(
              title: Text(widget.selectedUser.name),
              actions: [
                IconButton(
                  onPressed: () {
                    UrlLauncher.launch('tel:${widget.selectedUser.phone}');
                  },
                  icon: Icon(
                    Icons.call,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ],
            ),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: eventDBS.streamQueryList(args: [
              QueryArgsV2(
                "managerId",
                isEqualTo: widget.selectedUser.uid,
              ),
            ], orderBy: [
              OrderBy('start')
            ]),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                final events = snapshot.data;
                if (widget.currentUser.uid == widget.selectedUser.uid) {
                  events.forEach((AppEvent event) async {
                    if (event.date
                        .add(Duration(hours: 16))
                        .isBefore(DateTime.now())) {
                      await eventDBS.removeItem(event.id);
                    }
                  });
                }
                _groupEvents(events);
                selectedDate =
                    _calendarController.selectedDay ?? DateTime.now();
                _selectedEvents = _groupedEvents[selectedDate] ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.all(8.0),
                      child: TableCalendar(
                        calendarController: _calendarController,
                        // initialSelectedDay: DateTime.now(),
                        events: _groupedEvents,
                        startDay: DateTime.now(),
                        onDaySelected: (date, events, holidays) {
                          setState(() {});
                        },
                        weekendDays: [],
                        // calendarStyle: CalendarStyle(markersMaxAmount: 7),
                        startingDayOfWeek: StartingDayOfWeek.saturday,
                        initialCalendarFormat: CalendarFormat.week,
                        headerStyle: HeaderStyle(
                          centerHeaderTitle: true,
                          formatButtonShowsNext: false,
                        ),
                      ),
                    ),
                    if (selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                        child: Text(
                          intl.DateFormat('EEEE, dd MMMM, yyyy')
                              .format(selectedDate),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _selectedEvents.length,
                      itemBuilder: (BuildContext context, int index) {
                        AppEvent event = _selectedEvents[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.label,
                              color: event.confirmed == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Row(
                              children: [
                                Text('${intl.DateFormat('jm').format(event.start)}' +
                                    '\n' +
                                    '${intl.DateFormat('jm').format(event.end)}'),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                    width: 110,
                                    child: Center(
                                      child: Text(
                                        event.title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                              ],
                            ),
                            // subtitle:
                            // Text(intl.DateFormat("EEEE, dd MMMM, yyyy")
                            //     .format(event.date)),
                            onTap: () => pageTurn(
                                EventDetails(
                                  event: event,
                                  userId: widget.currentUser.uid,
                                ),
                                context)
                            // Navigator.pushNamed(
                            // context, AppRoutes.viewEvent,
                            // arguments: event)
                            ,
                            trailing: widget.currentUser.uid == event.managerId
                                ? IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => pageTurn(
                                        AddEventPage(
                                          event: event,
                                          currentUser: widget.currentUser,
                                          selectedUser: widget.selectedUser,
                                        ),
                                        context)
                                    //     Navigator.pushNamed(
                                    //   context,
                                    //   AppRoutes.editEvent,
                                    //   arguments: event,
                                    // )
                                    ,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: backgroundColor,
        child: Icon(Icons.add),
        onPressed: () {
          pageTurn(
              AddEventPage(
                selectedDate: _calendarController.selectedDay,
                currentUser: widget.currentUser,
                selectedUser: widget.selectedUser,
              ),
              context);
          // Navigator.pushNamed(context, AppRoutes.addEvent,
          //     arguments: _calendarController.selectedDay);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
