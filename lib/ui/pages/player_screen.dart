import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elml3b/models/user.dart';
import 'package:elml3b/repositories/fieldsRepository.dart';
import 'package:elml3b/ui/widgets/fields.dart';
import 'package:elml3b/ui/widgets/player_reservations.dart';
import 'package:elml3b/ui/widgets/user_drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:move_to_background/move_to_background.dart';

class PlayerScreen extends StatefulWidget {
  final userId;
  const PlayerScreen({this.userId});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  FieldsRepository fieldsRepository = FieldsRepository();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _firestore = FirebaseFirestore.instance;
  User user;
  bool _isInit = true;
  bool _loading = false;
  LocationData position;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _loading = true;
      });
      try {
        await getLocation();
        await getCurrentUser().then((value) {
          setState(() {
            _loading = false;
          });
        });
        await _firebaseMessaging.getToken().then((value) {
          _firestore.collection('users').doc(widget.userId).update({
            'token': value,
          });
        });
      } catch (e) {
        Flushbar(
          message: 'Check your connection',
          duration: Duration(seconds: 3),
        )..show(context);
      }
    }
    if (mounted)
      setState(() {
        _isInit = false;
      });
    super.didChangeDependencies();
  }

  getLocation() async {
    await checkLocationServicesInDevice();
  }

  Future getCurrentUser() async {
    user = await fieldsRepository.getUserDetails(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> taps = [
      Fields(
        userId: widget.userId,
        position: position,
        currentUser: user,
      ),
      PlayerReservations(userId: widget.userId),
    ];
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: DefaultTabController(
        length: 2,
        child: WillPopScope(
          onWillPop: () async {
            MoveToBackground.moveTaskToBack();
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('elml3b'),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48.0),
                child: Container(
                  height: 48.0,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TabBar(
                        tabs: <Widget>[
                          Tab(
                            text: 'Fields',
                          ),
                          Tab(
                            text: 'Reservations',
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            drawer: UserDrawer(user: user),
            body: TabBarView(
              children: taps,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkLocationServicesInDevice() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    Location location = Location();
    _serviceEnabled = await location.serviceEnabled();
    if (_serviceEnabled) {
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        position = await location.getLocation();
      } else {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted == PermissionStatus.granted) {
          position = await location.getLocation();
        } else {
          SystemNavigator.pop();
        }
      }
    } else {
      _serviceEnabled = await location.requestService();
      if (_serviceEnabled) {
        _permissionGranted = await location.hasPermission();
        if (_permissionGranted == PermissionStatus.granted) {
          position = await location.getLocation();
        } else {
          _permissionGranted = await location.requestPermission();
          if (_permissionGranted == PermissionStatus.granted) {
            position = await location.getLocation();
          } else {
            SystemNavigator.pop();
          }
        }
      } else {
        SystemNavigator.pop();
      }
    }
  }
}
