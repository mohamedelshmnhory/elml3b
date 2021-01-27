import 'package:elml3b/bloc/authentication/bloc.dart';
import 'package:elml3b/models/user.dart';
import 'package:elml3b/ui/pages/edit_profile.dart';
import 'package:elml3b/ui/pages/reports_screen.dart';
import 'package:elml3b/ui/widgets/pageTurn.dart';
import 'package:elml3b/ui/widgets/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagerDrawer extends StatelessWidget {
  final User user;

  const ManagerDrawer({this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: user == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('loading...')],
              )
            : Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.teal,
                      ),
                      padding: EdgeInsets.all(0),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 50,
                                ),
                                CircleAvatar(
                                  radius: 45,
                                  child: ClipOval(
                                    child: SizedBox(
                                        width: 180.0,
                                        height: 180.0,
                                        child:
                                            PhotoWidget(photoLink: user.photo)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 1.0),
                                  child: IconButton(
                                    onPressed: () {
                                      pageTurn(
                                          EditProfile(
                                            user: user,
                                          ),
                                          context);
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                                ),
                              ],
                            ),
                            Text(user.name),
                          ],
                        ),
                      )),
                  Column(
                    children: [
                      FlatButton(
                        onPressed: () {
                          pageTurn(
                              ReportsScreen(
                                userId: user.uid,
                              ),
                              context);
                        },
                        child: Text(
                          'reports',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Align(
                    alignment: Alignment.bottomCenter,
                    child: IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(LoggedOut());
                      },
                    ),
                  )),
                ],
              ));
  }
}
