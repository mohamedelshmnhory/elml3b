import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elml3b/models/user.dart';
import 'package:elml3b/repositories/fieldsRepository.dart';
import 'package:elml3b/ui/pages/field_table.dart';
import 'package:elml3b/ui/widgets/manager_drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:move_to_background/move_to_background.dart';

class ManagerScreen extends StatefulWidget {
  final userId;
  const ManagerScreen({this.userId});

  @override
  _ManagerScreenState createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  FieldsRepository fieldsRepository = FieldsRepository();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _firestore = FirebaseFirestore.instance;
  User user;
  bool _isInit = true;
  bool _loading = false;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _loading = false;
      });
      try {
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
        // TODO
      }
    }
    if (mounted)
      setState(() {
        _isInit = false;
      });
    super.didChangeDependencies();
  }

  Future getCurrentUser() async {
    user = await fieldsRepository.getUserDetails(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Scaffold(
          appBar: AppBar(
            title: Text('elml3b'),
            centerTitle: true,
          ),
          body: user == null
              ? Center(child: CircularProgressIndicator())
              : FieldTable(
                  currentUser: user,
                  selectedUser: user,
                ),
          drawer: ManagerDrawer(
            user: user,
          ),
        ),
      ),
    );
  }
}
