import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elml3b/repositories/userRepository.dart';
import 'package:meta/meta.dart';
import './bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  UserRepository _userRepository;

  ProfileBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  ProfileState get initialState => ProfileState.empty();

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is NameChanged) {
      yield* _mapNameChangedToState(event.name);
    } else if (event is AddressChanged) {
      yield* _mapAgeChangedToState(event.address);
    } else if (event is PhoneChanged) {
      yield* _mapGenderChangedToState(event.phone);
    } else if (event is HourPriceChanged) {
      yield* _mapInterestedInChangedToState(event.hourPrice);
    } else if (event is LocationChanged) {
      yield* _mapLocationChangedToState(event.location);
    } else if (event is PhotoChanged) {
      yield* _mapPhotoChangedToState(event.photo);
    } else if (event is Submitted) {
      final uid = await _userRepository.getUser();
      yield* _mapSubmittedToState(
        photo: event.photo,
        name: event.name,
        type: event.type,
        address: event.address,
        hourPrice: event.hourPrice,
        userId: uid,
        phone: event.phone,
        location: event.location,
      );
    }
  }

  Stream<ProfileState> _mapNameChangedToState(String name) async* {
    yield state.update(
      isNameEmpty: name == null,
    );
  }

  Stream<ProfileState> _mapPhotoChangedToState(File photo) async* {
    yield state.update(
      isPhotoEmpty: photo == null,
    );
  }

  Stream<ProfileState> _mapAgeChangedToState(String address) async* {
    yield state.update(
      isAddressEmpty: address == null,
    );
  }

  Stream<ProfileState> _mapGenderChangedToState(String phone) async* {
    yield state.update(
      isPhoneEmpty: phone == null,
    );
  }

  Stream<ProfileState> _mapInterestedInChangedToState(String hourPrice) async* {
    yield state.update(
      isHourPriceEmpty: hourPrice == null,
    );
  }

  Stream<ProfileState> _mapLocationChangedToState(GeoPoint location) async* {
    yield state.update(
      isLocationEmpty: location == null,
    );
  }

  Stream<ProfileState> _mapSubmittedToState(
      {@required File photo,
      @required String type,
      @required String name,
      @required String userId,
      @required String phone,
      @required String address,
      @required String hourPrice,
      @required GeoPoint location}) async* {
    yield ProfileState.loading();
    try {
      await _userRepository.profileSetup(
          photo, userId, name, type, phone, location, address, hourPrice);
      yield ProfileState.success();
    } catch (_) {
      yield ProfileState.failure();
    }
  }
}
