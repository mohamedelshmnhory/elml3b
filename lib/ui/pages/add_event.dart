import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elml3b/models/app_event.dart';
import 'package:elml3b/models/user.dart';
import 'package:elml3b/services/event_firestore_service.dart';
import 'package:firebase_helpers/firebase_helpers.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart' as intl;

class AddEventPage extends StatefulWidget {
  final DateTime selectedDate;
  final AppEvent event;
  final User currentUser, selectedUser;

  const AddEventPage(
      {Key key,
      this.selectedDate,
      this.event,
      this.selectedUser,
      this.currentUser})
      : super(key: key);
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormBuilderState>();
  String day = intl.DateFormat.d().format(DateTime.now()).toString();
  String month = intl.DateFormat.M().format(DateTime.now()).toString();
  int hour = 0;
  int minute = 0;
  double money = 0;
  bool _isInit = true;
  double price;
  bool _loading = false;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      if (widget.event != null) {
        price = widget.event.end.difference(widget.event.start).inMinutes *
            (int.parse(widget.event.hourPrice) / 60);
        try {
          await _firestore
              .collection("logs")
              .doc(widget.currentUser.uid)
              .collection('money')
              .doc('$day - $month')
              .get()
              .then((value) {
            money = value.data()['money'] > 0 ? value.data()['money'] : 0;
          });
        } catch (e) {
          // TODO
        }
      }
    }
    if (mounted)
      setState(() {
        _isInit = false;
      });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(widget.selectedUser.name),
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            // color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Builder(
        builder: (context) => Container(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    if (widget.event == null)
                      FormBuilderDateTimePicker(
                        name: "date",
                        initialValue: widget.selectedDate ??
                            widget.event?.date ??
                            DateTime.now(),
                        initialDate: DateTime.now(),
                        fieldHintText: "Add Date",
                        initialDatePickerMode: DatePickerMode.day,
                        inputType: InputType.date,
                        format: intl.DateFormat('EEEE, dd MMMM, yyyy'),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.calendar_today_sharp),
                        ),
                      ),
                    Divider(),
                    FormBuilderTextField(
                      readOnly: widget.event != null ? true : false,
                      name: "title",
                      initialValue:
                          widget.event?.title ?? widget.currentUser.name,
                      decoration: InputDecoration(
                          hintText: "Add Title",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(left: 48.0)),
                    ),
                    FormBuilderTextField(
                      readOnly: widget.event != null ? true : false,
                      name: "userPhone",
                      initialValue:
                          widget.event?.userPhone ?? widget.currentUser.phone,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: "Add Phone",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(left: 48.0)),
                    ),
                    Divider(),
                    if (widget.event != null)
                      Column(
                        children: [
                          FormBuilderSwitch(
                            name: "confirmed",
                            initialValue: widget.event?.confirmed ?? false,
                            title: Text("confirmed"),
                            controlAffinity: ListTileControlAffinity.leading,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (value) async {
                              await eventDBS.updateData(
                                  widget.event.id, {'confirmed': value});
                              if (value == true) {
                                money += price;
                                try {
                                  await _firestore
                                      .collection('logs')
                                      .doc(widget.currentUser.uid)
                                      .collection('money')
                                      .doc('$day - $month')
                                      .set({
                                    'date': '$day - $month',
                                    'money': money,
                                  });
                                } catch (e) {
                                  // TODO
                                }
                              }
                              if (value == false) {
                                money -= price;
                                try {
                                  await _firestore
                                      .collection('logs')
                                      .doc(widget.currentUser.uid)
                                      .collection('money')
                                      .doc('$day - $month')
                                      .set({
                                    'date': '$day - $month',
                                    'money': money,
                                  });
                                } catch (e) {
                                  // TODO
                                }
                              }
                            },
                          ),
                          Text(
                            '$price LE',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    if (widget.event == null)
                      Column(
                        children: [
                          // Text('Start'),
                          Row(
                            children: [
                              Container(
                                width: size.width * .4,
                                child: FormBuilderTextField(
                                  readOnly: widget.event != null ? true : false,
                                  name: "players",
                                  // initialValue: 0.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: 'Players number',
                                      labelStyle: TextStyle(fontSize: 13),
                                      hintText: "Add number",
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.only(left: 48.0)),
                                ),
                              ),
                              Container(
                                width: size.width * .4,
                                child: FormBuilderTextField(
                                  readOnly: widget.event != null ? true : false,
                                  name: "needPlayers",
                                  // initialValue: 0.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: 'Players needed',
                                      labelStyle: TextStyle(fontSize: 13),
                                      hintText: "Add number",
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.only(left: 48.0)),
                                ),
                              ),
                            ],
                          ),
                          FormBuilderDateTimePicker(
                            name: "start",
                            fieldHintText: "Add Date",
                            inputType: InputType.time,
                            format: intl.DateFormat.jm(),
                            decoration: InputDecoration(
                              labelText: 'Start',
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.access_time_outlined),
                            ),
                          ),
                          Divider(),
                          Text(
                            'Duration',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        if (hour > 0)
                                          setState(() {
                                            hour -= 1;
                                          });
                                      }),
                                  Text(
                                    '$hour',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        if (hour < 6)
                                          setState(() {
                                            hour += 1;
                                          });
                                      }),
                                ],
                              ),
                              Container(
                                width: 100,
                                child: FlatButton(
                                    onPressed: () {
                                      setState(() {
                                        minute = 30;
                                      });
                                    },
                                    child: Text('+ 30 min')),
                              ),
                            ],
                          ),
                          Text('$hour : $minute'),
                        ],
                      ),
                    Divider(),
                  ],
                ),
              ),
              if (!_loading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _save(context).whenComplete(() {
                        setState(() {
                          _loading = false;
                        });
                      });
                    },
                    child: Text("Add"),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext ctx) async {
    _formKey.currentState.save();
    final data = Map<String, dynamic>.from(_formKey.currentState.value);
    if (widget.event != null) {
      await eventDBS.updateData(widget.event.id, data);
      Navigator.of(context).pop();
    } else {
      if (data["start"] == null) {
        Flushbar(
          message: 'please enter start Time',
          duration: Duration(seconds: 3),
        )..show(context);
      } else if (hour == 0 && minute == 0) {
        Flushbar(
          message: 'please enter duration',
          duration: Duration(seconds: 3),
        )..show(context);
      } else {
        Scaffold.of(ctx)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Loading..'),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        setState(() {
          _loading = true;
        });
        // await Future.delayed(Duration(seconds: 1));
        data['confirmed'] = false;
        data['photo'] = widget.currentUser.photo;
        data['fieldName'] = widget.selectedUser.name;
        data['hourPrice'] = widget.selectedUser.hourPrice;
        data["date"] = (data["date"] as DateTime).millisecondsSinceEpoch;
        data["start"] = (data["start"] as DateTime).millisecondsSinceEpoch;
        data["end"] = (DateTime.fromMillisecondsSinceEpoch(data["start"]))
            .add(Duration(hours: hour, minutes: minute))
            .millisecondsSinceEpoch;
        data['userId'] = widget.currentUser.uid;

        await eventDBS.getQueryList(args: [
          QueryArgsV2(
            "managerId",
            isEqualTo: widget.selectedUser.uid,
          ),
          QueryArgsV2(
            "date",
            isEqualTo: data["date"],
          ),
        ]).then((querySnapshot) {
          DateTime myStart = DateTime.fromMillisecondsSinceEpoch(data["start"]);
          DateTime myEnd = DateTime.fromMillisecondsSinceEpoch(data["end"]);
          bool isExist = false;
          if (querySnapshot.isNotEmpty) {
            querySnapshot.forEach((event) {
              if (myStart.isAtSameMomentAs(event.start) ||
                  myEnd.isAtSameMomentAs(event.end) ||
                  (myStart.isAfter(event.start) &&
                      myStart.isBefore(event.end)) ||
                  (myEnd.isAfter(event.start) && myEnd.isBefore(event.end)) ||
                  (myStart.isBefore(event.start) && myEnd.isAfter(event.end))) {
                isExist = true;
              }
            });
            return isExist;
          } else
            return false;
        }).then((value) async {
          if (value == false) {
            await eventDBS.create({
              ...data,
              "managerId": widget.selectedUser.uid,
            });
            Navigator.pop(context);
          } else {
            _showSnackBar(ctx, 'This time is already exist');
          }
        });
      }
    }
  }

  _showSnackBar(BuildContext ctx, text) {
    Scaffold.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(text),
              Icon(Icons.error),
            ],
          ),
        ),
      );
  }
}
