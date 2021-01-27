import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String name;
  String address;
  String phone;
  String photo;
  String hourPrice;
  GeoPoint location;
  String type;

  User(
      {this.uid,
      this.name,
      this.address,
      this.phone,
      this.photo,
      this.hourPrice,
      this.location,
      this.type});
}
