import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elml3b/models/user.dart';

class FieldsRepository {
  final FirebaseFirestore _firestore;

  FieldsRepository({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMatchedList(userId) {
    return _firestore
        .collection('users')
        .where('type', isEqualTo: 'manager')
        .snapshots();
  }

  Future<User> getUserDetails(userId) async {
    User _user = User();

    await _firestore.collection('users').doc(userId).get().then((user) {
      _user.uid = user.id;
      _user.name = user['name'];
      _user.photo = user['photoUrl'];
      _user.address = user['address'];
      _user.location = user['location'];
      _user.hourPrice = user['hourPrice'];
      _user.phone = user['phone'];
      _user.type = user['type'];
    });

    return _user;
  }
}
