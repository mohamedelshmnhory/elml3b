import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class NameChanged extends ProfileEvent {
  final String name;

  NameChanged({@required this.name});

  @override
  List<Object> get props => [name];
}

class PhotoChanged extends ProfileEvent {
  final File photo;

  PhotoChanged({@required this.photo});

  @override
  List<Object> get props => [photo];
}

class AddressChanged extends ProfileEvent {
  final String address;

  AddressChanged({@required this.address});

  @override
  List<Object> get props => [address];
}

class PhoneChanged extends ProfileEvent {
  final String phone;

  PhoneChanged({@required this.phone});

  @override
  List<Object> get props => [phone];
}

class HourPriceChanged extends ProfileEvent {
  final String hourPrice;

  HourPriceChanged({@required this.hourPrice});

  @override
  List<Object> get props => [hourPrice];
}



class LocationChanged extends ProfileEvent {
  final GeoPoint location;

  LocationChanged({@required this.location});

  @override
  List<Object> get props => [location];
}

class Submitted extends ProfileEvent {
  final String name, type, phone, address, hourPrice;
  final GeoPoint location;
  final File photo;

  Submitted(
      {@required this.name,
      @required this.type,
      @required this.phone,
      @required this.location,
      @required this.address,
      @required this.hourPrice,
      @required this.photo});

  @override
  List<Object> get props =>
      [location, name, phone, type, photo, address, hourPrice];
}
