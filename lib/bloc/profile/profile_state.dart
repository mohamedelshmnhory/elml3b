import 'package:meta/meta.dart';

@immutable
class ProfileState {
  final bool isPhotoEmpty;
  final bool isNameEmpty;
  final bool isAddressEmpty;
  final bool isHourPriceEmpty;
  final bool isPhoneEmpty;
  final bool isLocationEmpty;
  final bool isFailure;
  final bool isSubmitting;
  final bool isSuccess;

  bool get isFormValid =>
      isPhotoEmpty &&
      isNameEmpty &&
      isAddressEmpty &&
      isHourPriceEmpty &&
      isPhoneEmpty;

  ProfileState({
    @required this.isPhotoEmpty,
    @required this.isNameEmpty,
    @required this.isAddressEmpty,
    @required this.isHourPriceEmpty,
    @required this.isPhoneEmpty,
    @required this.isLocationEmpty,
    @required this.isFailure,
    @required this.isSubmitting,
    @required this.isSuccess,
  });

  factory ProfileState.empty() {
    return ProfileState(
      isPhotoEmpty: false,
      isFailure: false,
      isSuccess: false,
      isSubmitting: false,
      isNameEmpty: false,
      isAddressEmpty: false,
      isHourPriceEmpty: false,
      isPhoneEmpty: false,
      isLocationEmpty: false,
    );
  }

  factory ProfileState.loading() {
    return ProfileState(
      isPhotoEmpty: false,
      isFailure: false,
      isSuccess: false,
      isSubmitting: true,
      isNameEmpty: false,
      isAddressEmpty: false,
      isHourPriceEmpty: false,
      isPhoneEmpty: false,
      isLocationEmpty: false,
    );
  }

  factory ProfileState.failure() {
    return ProfileState(
      isPhotoEmpty: false,
      isFailure: true,
      isSuccess: false,
      isSubmitting: false,
      isNameEmpty: false,
      isAddressEmpty: false,
      isHourPriceEmpty: false,
      isPhoneEmpty: false,
      isLocationEmpty: false,
    );
  }

  factory ProfileState.success() {
    return ProfileState(
      isPhotoEmpty: false,
      isFailure: false,
      isSuccess: true,
      isSubmitting: false,
      isNameEmpty: false,
      isAddressEmpty: false,
      isHourPriceEmpty: false,
      isPhoneEmpty: false,
      isLocationEmpty: false,
    );
  }

  ProfileState update({
    bool isPhotoEmpty,
    bool isNameEmpty,
    bool isAddressEmpty,
    bool isPhoneEmpty,
    bool isHourPriceEmpty,
    bool isLocationEmpty,
  }) {
    return copyWith(
      isFailure: false,
      isSuccess: false,
      isSubmitting: false,
      isPhotoEmpty: isPhotoEmpty,
      isNameEmpty: isNameEmpty,
      isAddressEmpty: isAddressEmpty,
      isPhoneEmpty: isPhoneEmpty,
      isHourPriceEmpty: isHourPriceEmpty,
      isLocationEmpty: isLocationEmpty,
    );
  }

  ProfileState copyWith({
    bool isPhotoEmpty,
    bool isNameEmpty,
    bool isAddressEmpty,
    bool isPhoneEmpty,
    bool isHourPriceEmpty,
    bool isLocationEmpty,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return ProfileState(
      isPhotoEmpty: isPhotoEmpty ?? this.isPhotoEmpty,
      isNameEmpty: isNameEmpty ?? this.isNameEmpty,
      isLocationEmpty: isLocationEmpty ?? this.isLocationEmpty,
      isPhoneEmpty: isPhoneEmpty ?? this.isPhoneEmpty,
      isHourPriceEmpty: isHourPriceEmpty ?? this.isHourPriceEmpty,
      isAddressEmpty: isAddressEmpty ?? this.isAddressEmpty,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }
}
