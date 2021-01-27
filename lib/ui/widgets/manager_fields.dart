import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elml3b/bloc/fields/fields_bloc.dart';
import 'package:elml3b/models/user.dart';
import 'package:elml3b/repositories/fieldsRepository.dart';
import 'package:elml3b/ui/pages/field_table.dart';
import 'package:elml3b/ui/widgets/pageTurn.dart';
import 'package:elml3b/ui/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagerFields extends StatefulWidget {
  final String userId;
  const ManagerFields({this.userId});
  @override
  _ManagerFieldsState createState() => _ManagerFieldsState();
}

class _ManagerFieldsState extends State<ManagerFields> {
  FieldsRepository fieldsRepository = FieldsRepository();
  FieldsBloc _fieldsBloc;
  @override
  void initState() {
    _fieldsBloc = FieldsBloc(fieldsRepository: fieldsRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder(
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
                        List items = [];
                        for (var item in user) {
                          if (item.data()['uid'] == widget.userId)
                            items.add(item);
                        }
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () async {
                                  User selectedUser = await fieldsRepository
                                      .getUserDetails(items[index].documentID);
                                  User currentUser = await fieldsRepository
                                      .getUserDetails(widget.userId);
                                  try {
                                    pageTurn(
                                        FieldTable(
                                          currentUser: currentUser,
                                          selectedUser: selectedUser,
                                        ),
                                        context);
                                  } catch (e) {
                                    print(e.toString());
                                  }
                                },
                                child: profileWidget(
                                  padding: size.height * 0.01,
                                  photo: items[index].data()['photoUrl'],
                                  photoWidth: size.width,
                                  photoHeight: size.height * 0.3,
                                  clipRadius: size.height * 0.01,
                                  containerHeight: size.height * 0.09,
                                  containerWidth: size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      items[index].data()['name'] +
                                          '\n' +
                                          items[index].data()['address'] +
                                          '\n' +
                                          items[index].data()['hourPrice'],
                                      style: TextStyle(color: Colors.white),
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
        });
  }
}
