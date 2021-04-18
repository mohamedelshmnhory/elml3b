import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elml3b/models/user.dart';
import 'package:elml3b/ui/pages/manager_screen.dart';
import 'package:elml3b/ui/pages/player_screen.dart';
import 'package:elml3b/ui/widgets/pageTurn.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';

class EditProfile extends StatefulWidget {
  final User user;
  const EditProfile({Key key, this.user}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _hourPriceController = TextEditingController();
  String type;
  File photo;
  bool _loading = false;

  Future<void> _onSubmitted() async {
    setState(() {
      _loading = true;
    });
    if (photo != null) {
      UploadTask storageUploadTask;
      storageUploadTask = FirebaseStorage.instance
          .ref()
          .child('userPhotos')
          .child(widget.user.uid)
          .child(widget.user.uid)
          .putFile(photo);
      await storageUploadTask.then((ref) async {
        await ref.ref.getDownloadURL().then((url) async {
          await _firestore.collection('users').doc(widget.user.uid).update({
            'photoUrl': url,
          });
        });
      });
    }

    await _firestore.collection('users').doc(widget.user.uid).update({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'hourPrice': _hourPriceController.text,
    });
  }

  @override
  void initState() {
    _nameController.text = widget.user.name;
    _addressController.text = widget.user.address;
    _phoneController.text = widget.user.phone;
    _hourPriceController.text = widget.user.hourPrice;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _hourPriceController.dispose();
    super.dispose();
  }

  Future getImage() async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    setState(() {
      photo = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    type = widget.user.type;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: _loading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (type == 'player')
                    Column(
                      children: [
                        Container(
                          width: size.width,
                          child: CircleAvatar(
                            radius: size.width * 0.3,
                            backgroundColor: Colors.white,
                            child: photo == null
                                ? GestureDetector(
                                    onTap: () {
                                      getImage();
                                    },
                                    child: ClipOval(
                                        child: SizedBox(
                                            height: 200,
                                            width: 200,
                                            child: Image.network(
                                              widget.user.photo,
                                              fit: BoxFit.cover,
                                            ))),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      getImage();
                                    },
                                    child: CircleAvatar(
                                      radius: size.width * 0.3,
                                      backgroundImage: FileImage(photo),
                                    ),
                                  ),
                          ),
                        ),
                        textFieldWidget(
                            _nameController, 'Name', size, TextInputType.text),
                        textFieldWidget(_phoneController, 'Phone', size,
                            TextInputType.number),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          child: GestureDetector(
                            onTap: () async {
                              await _onSubmitted().then((value) {
                                pageTurn(
                                    PlayerScreen(
                                      userId: widget.user.uid,
                                    ),
                                    context);
                              });
                            },
                            child: Container(
                              width: size.width * 0.8,
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(size.height * 0.05),
                              ),
                              child: Center(
                                  child: Text(
                                "Save",
                                style: TextStyle(
                                    fontSize: size.height * 0.025,
                                    color: Colors.blue),
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (type == 'manager')
                    Column(
                      children: [
                        Container(
                          width: size.width,
                          child: CircleAvatar(
                            radius: size.width * 0.3,
                            backgroundColor: Colors.white,
                            child: photo == null
                                ? GestureDetector(
                                    onTap: () {
                                      getImage();
                                    },
                                    child: ClipOval(
                                        child: SizedBox(
                                            height: 200,
                                            width: 200,
                                            child: Image.network(
                                              widget.user.photo,
                                              fit: BoxFit.cover,
                                            ))),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      getImage();
                                    },
                                    child: CircleAvatar(
                                      radius: size.width * 0.3,
                                      backgroundImage: FileImage(photo),
                                    ),
                                  ),
                          ),
                        ),
                        textFieldWidget(
                            _nameController, "Name", size, TextInputType.text),
                        textFieldWidget(_addressController, "Address", size,
                            TextInputType.text),
                        textFieldWidget(_phoneController, "Phone", size,
                            TextInputType.number),
                        textFieldWidget(_hourPriceController, "Hour price",
                            size, TextInputType.number),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          child: GestureDetector(
                            onTap: () async {
                              await _onSubmitted().then((value) {
                                pageTurn(
                                    ManagerScreen(
                                      userId: widget.user.uid,
                                    ),
                                    context);
                                setState(() {
                                  _loading = false;
                                });
                              });
                            },
                            child: Container(
                              width: size.width * 0.8,
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(size.height * 0.05),
                              ),
                              child: Center(
                                  child: Text(
                                "Save",
                                style: TextStyle(
                                    fontSize: size.height * 0.025,
                                    color: Colors.blue),
                              )),
                            ),
                          ),
                        ),
                      ],
                    )
                ],
              ),
      ),
    );
  }
}

Widget textFieldWidget(controller, text, size, type) {
  return Padding(
    padding: EdgeInsets.all(size.height * 0.02),
    child: TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: text,
        labelStyle:
            TextStyle(color: Colors.white, fontSize: size.height * 0.03),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
        ),
      ),
    ),
  );
}
