import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elml3b/bloc/fields/fields_bloc.dart';
import 'package:elml3b/models/user.dart';
import 'package:elml3b/repositories/fieldsRepository.dart';
import 'package:elml3b/ui/pages/field_table.dart';
import 'package:elml3b/ui/widgets/pageTurn.dart';
import 'package:elml3b/ui/widgets/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Fields extends StatefulWidget {
  final String userId;
  final LocationData position;
  final User currentUser;
  const Fields({this.userId, this.position, this.currentUser});
  @override
  _FieldsState createState() => _FieldsState();
}

class _FieldsState extends State<Fields> {
  FieldsRepository fieldsRepository = FieldsRepository();
  FieldsBloc _fieldsBloc;

  bool _loading = false;

  double calculateDistance(GeoPoint userLocation) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((userLocation.latitude - widget.position.latitude) * p) / 2 +
        c(widget.position.latitude * p) *
            c(userLocation.latitude * p) *
            (1 - c((userLocation.longitude - widget.position.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {
    _fieldsBloc = FieldsBloc(fieldsRepository: fieldsRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: BlocBuilder(
          bloc: _fieldsBloc,
          builder: (BuildContext context, FieldsState state) {
            if (state is LoadingState) {
              _fieldsBloc.add(LoadListsEvent(userId: widget.userId));
              return CircularProgressIndicator();
            }
            if (state is LoadUserState) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    // pinned: true,
                    backgroundColor: Colors.white,
                    title: Text(
                      "10 km",
                      style: TextStyle(color: Colors.black, fontSize: 30.0),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: state.matchedList,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('...'),
                              ),
                            ),
                          );
                        }
                        if (snapshot.data.docs != null &&
                            widget.position != null) {
                          final user = snapshot.data.docs;
                          List items = [];
                          for (var item in user) {
                            var dis =
                                calculateDistance(item.data()['location']);
                            if (dis < 10) items.add(item);
                          }
                          return SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      _loading = true;
                                    });
                                    User selectedUser =
                                        await fieldsRepository.getUserDetails(
                                            items[index].documentID);
                                    try {
                                      pageTurn(
                                          FieldTable(
                                            currentUser: widget.currentUser,
                                            selectedUser: selectedUser,
                                          ),
                                          context);
                                    } catch (e) {
                                      print(e.toString());
                                    }
                                    setState(() {
                                      _loading = false;
                                    });
                                  },
                                  child: profileWidget(
                                    padding: size.height * 0.01,
                                    photo: items[index].data()['photoUrl'],
                                    photoWidth: size.width,
                                    photoHeight: size.height * 0.3,
                                    clipRadius: size.height * 0.01,
                                    containerHeight: size.height * 0.13,
                                    containerWidth: size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            items[index].data()['name'],
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            items[index].data()['address'],
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            '${items[index].data()['hourPrice']}  LE',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: items.length,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 2.3,
                            ),
                          );
                        } else {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('Loading...'),
                              ),
                            ),
                          );
                        }
                      }),
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.white,
                    title: Text(
                      "All",
                      style: TextStyle(color: Colors.black, fontSize: 30.0),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: state.matchedList,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('...'),
                              ),
                            ),
                          );
                        }
                        if (snapshot.data.docs != null) {
                          final user = snapshot.data.docs;
                          return SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      _loading = true;
                                    });
                                    User selectedUser = await fieldsRepository
                                        .getUserDetails(user[index].id);
                                    try {
                                      pageTurn(
                                          FieldTable(
                                            currentUser: widget.currentUser,
                                            selectedUser: selectedUser,
                                          ),
                                          context);
                                    } catch (e) {
                                      print(e.toString());
                                    }
                                    setState(() {
                                      _loading = false;
                                    });
                                  },
                                  child: profileWidget(
                                    padding: size.height * 0.01,
                                    photo: user[index].data()['photoUrl'],
                                    photoWidth: size.width,
                                    photoHeight: size.height * 0.3,
                                    clipRadius: size.height * 0.01,
                                    containerHeight: size.height * 0.13,
                                    containerWidth: size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            user[index].data()['name'],
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            user[index].data()['address'],
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            '${user[index].data()['hourPrice']}  LE',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: user.length,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 2.3,
                            ),
                          );
                        } else {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('..'),
                              ),
                            ),
                          );
                        }
                      }),
                ],
              );
            }
            return Container();
          }),
    );
  }
}
