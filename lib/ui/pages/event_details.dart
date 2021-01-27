import 'package:elml3b/models/app_event.dart';
import 'package:elml3b/services/event_firestore_service.dart';
import 'package:elml3b/ui/widgets/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class EventDetails extends StatefulWidget {
  final AppEvent event;
  final String userId;

  const EventDetails({Key key, this.event, this.userId}) : super(key: key);

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    String players = widget.event.players;
    String needPlayers = widget.event.needPlayers;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.fieldName),
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.userId == widget.event.managerId ||
              widget.userId == widget.event.userId)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Warinig!"),
                        content: Text("Are you sure you want to delete?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Delete")),
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (confirm) {
                  await eventDBS.removeItem(widget.event.id);
                  Navigator.pop(context);
                }
              },
            )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            widget.event.confirmed ? "Confirmed" : "Unconfirmed",
            style: TextStyle(
                color: widget.event.confirmed ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 45,
                    child: ClipOval(
                      child: SizedBox(
                          width: 180.0,
                          height: 180.0,
                          child: PhotoWidget(photoLink: widget.event.photo)),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 150,
                            child: Center(
                              child: Text(
                                widget.event.title,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                          ),
                          if (widget.userId != widget.event.userId)
                            IconButton(
                              onPressed: () {
                                UrlLauncher.launch(
                                    'tel:${widget.event.userPhone}');
                              },
                              icon: Icon(
                                Icons.call,
                                color: Colors.green,
                                size: 35,
                              ),
                            ),
                        ],
                      ),
                      Text(intl.DateFormat("EEEE, dd MMMM, yyyy")
                          .format(widget.event.date)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'start :  ${intl.DateFormat('jm').format(widget.event.start)}' +
                '\n' +
                'end :    ${intl.DateFormat('jm').format(widget.event.end)}',
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(height: 30),
          Row(
            children: [
              Text(
                'players number :   $players',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (widget.userId == widget.event.userId)
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * .30,
                                child: FormBuilder(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FormBuilderTextField(
                                        name: "players",
                                        initialValue: players,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            labelText: 'Players Number',
                                            hintText: "Add Number",
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 48.0)),
                                      ),
                                      FormBuilderTextField(
                                        name: "needPlayers",
                                        initialValue: needPlayers,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            labelText: 'Players Needed',
                                            hintText: "Add Number",
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 48.0)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          _formKey.currentState.save();
                                          final data =
                                              Map<String, dynamic>.from(
                                                  _formKey.currentState.value);
                                          await eventDBS.updateData(
                                              widget.event.id, data);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text("Save"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ));
                  },
                  color: Colors.red,
                ),
            ],
          ),
          Text(
            'players needed  :   $needPlayers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          Text(
            'Price \n           ${widget.event.end.difference(widget.event.start).inMinutes * (int.parse(widget.event.hourPrice) / 60)} LE',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
