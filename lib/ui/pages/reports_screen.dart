import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  final userId;
  ReportsScreen({this.userId});
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'reports',
          ),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton(
              onSelected: (value) async {
                await _firestore
                    .collection('logs')
                    .doc(widget.userId)
                    .collection('money')
                    .get()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.docs) {
                    ds.reference.delete();
                  }
                });
              },
              icon: Icon(
                Icons.more_vert,
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text('Clear'),
                  value: 'Clear',
                ),
              ],
            ),
          ]),
      body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('logs')
              .doc(widget.userId)
              .collection('money')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data == null)
              return Center(child: CircularProgressIndicator());
            final menInf = snapshot.data.docs;

            return ListView.builder(
              itemCount: menInf.length,
              itemBuilder: (c, i) => Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          menInf[i].data()['date'],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${menInf[i].data()['money'].toString()} LE',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )),
            );
          }),
    );
  }
}
