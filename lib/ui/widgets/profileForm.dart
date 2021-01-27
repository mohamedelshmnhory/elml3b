import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elml3b/bloc/authentication/bloc.dart';
import 'package:elml3b/bloc/profile/bloc.dart';
import 'package:elml3b/bloc/profile/profile_bloc.dart';
// import 'package:elml3b/repositories/userRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import 'gender.dart';

class ProfileForm extends StatefulWidget {
  // final UserRepository _userRepository;
  //
  // ProfileForm({@required UserRepository userRepository})
  //     : assert(userRepository != null),
  //       _userRepository = userRepository;

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _hourPriceController = TextEditingController();
  String type;
  File photo;
  GeoPoint location;
  ProfileBloc _profileBloc;

  //UserRepository get _userRepository => widget._userRepository;

  bool get isFilled {
    if (type == 'player')
      return _nameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty;
    if (type == 'manager')
      return _nameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _addressController.text.isNotEmpty &&
          _hourPriceController.text.isNotEmpty;
    else
      return false;
  }

  bool isButtonEnabled(ProfileState state) {
    return isFilled && !state.isSubmitting && photo != null;
  }

  LocationData position;
  _getLocation() async {
    await checkLocationServicesInDevice().then((value) {
      setState(() {
        location = GeoPoint(position.latitude, position.longitude);
      });
    });
  }

  _onSubmitted() async {
    await _getLocation();
    _profileBloc.add(
      Submitted(
          name: _nameController.text,
          address: _addressController.text,
          hourPrice: _hourPriceController.text,
          phone: _phoneController.text,
          location: location,
          type: type,
          photo: photo),
    );
  }

  @override
  void initState() {
    _getLocation();
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    _nameController.addListener(_onNameChanged);
    _addressController.addListener(_onAddressChanged);
    _phoneController.addListener(_onPhoneChanged);
    _hourPriceController.addListener(_onHourPriceChanged);
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
    // File compressedImage =
    //     await FlutterNativeImage.compressImage(image.path, quality: 70);
    setState(() {
      photo = image;
      //print('Image Path $_image');
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocListener<ProfileBloc, ProfileState>(
      //bloc: _profileBloc,
      listener: (context, state) {
        if (state.isFailure) {
          print("Failed");
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Profile Creation Unsuccesful'),
                    Icon(Icons.error)
                  ],
                ),
              ),
            );
        }
        if (state.isSubmitting) {
          print("Submitting");
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Submitting'),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          print("Success!");
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: backgroundColor,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.height * 0.02),
                        child: Text(
                          "You Are",
                          style: TextStyle(
                              color: Colors.white, fontSize: size.width * 0.09),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          typeWidget(
                              Icons.sports_handball, "player", size, type, () {
                            setState(() {
                              type = "player";
                            });
                          }),
                          typeWidget(Icons.person, "manager", size, type, () {
                            setState(() {
                              type = "manager";
                            });
                          }),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                    ],
                  ),
                  if (type == 'player')
                    Column(
                      children: [
                        Container(
                          width: size.width,
                          child: CircleAvatar(
                            radius: size.width * 0.3,
                            backgroundColor: Colors.white54,
                            child: photo == null
                                ? GestureDetector(
                                    onTap: () {
                                      getImage();
                                    },
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 50,
                                    ),
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
                            onTap: () {
                              if (isButtonEnabled(state)) {
                                _onSubmitted();
                              } else {}
                            },
                            child: Container(
                              width: size.width * 0.8,
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                color: isButtonEnabled(state)
                                    ? Colors.white
                                    : Colors.grey,
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
                            backgroundColor: Colors.white54,
                            child: photo == null
                                ? GestureDetector(
                                    onTap: () {
                                      getImage();
                                    },
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 50,
                                    ),
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
                            onTap: () {
                              if (isButtonEnabled(state)) {
                                _onSubmitted();
                              } else {}
                            },
                            child: Container(
                              width: size.width * 0.8,
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                color: isButtonEnabled(state)
                                    ? Colors.white
                                    : Colors.grey,
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
        },
      ),
    );
  }

  void _onNameChanged() {
    _profileBloc.add(
      NameChanged(name: _nameController.text),
    );
  }

  void _onAddressChanged() {
    _profileBloc.add(
      AddressChanged(address: _addressController.text),
    );
  }

  void _onPhoneChanged() {
    _profileBloc.add(
      PhoneChanged(phone: _phoneController.text),
    );
  }

  void _onHourPriceChanged() {
    _profileBloc.add(
      HourPriceChanged(hourPrice: _hourPriceController.text),
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
