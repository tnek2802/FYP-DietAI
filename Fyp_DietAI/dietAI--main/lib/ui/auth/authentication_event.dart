part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {}

class LoginWithEmailAndPasswordEvent extends AuthenticationEvent {
  String email;
  String password;

  LoginWithEmailAndPasswordEvent({required this.email, required this.password});
}

// class LoginWithFacebookEvent extends AuthenticationEvent {}

class LoginWithAppleEvent extends AuthenticationEvent {}

class LoginWithPhoneNumberEvent extends AuthenticationEvent {
  auth.PhoneAuthCredential credential;
  String phoneNumber;
  String? firstName, lastName;
  Uint8List? imageData;

  LoginWithPhoneNumberEvent({
    required this.credential,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.imageData,
  });
}

class SignupWithEmailAndPasswordEvent extends AuthenticationEvent {
  String emailAddress;
  String password;
  Uint8List? imageData;
  String? firstName;
  String? lastName;
  String? age;
  String? weight;
  String? height;
  String? gender;
  String? medicalHistory;
  String? foodPreferences;

  SignupWithEmailAndPasswordEvent(
      {required this.emailAddress,
      required this.password,
      this.imageData,
      this.firstName = 'Anonymous',
      this.lastName = 'User',
      this.age = 'Age',
      this.weight = 'Weight',
      this.height = 'Height',
      this.gender = 'Gender',
      this.medicalHistory = 'Normal',
      this.foodPreferences = 'Vegetarian'});
}

class LogoutEvent extends AuthenticationEvent {
  LogoutEvent();
}

class FinishedOnBoardingEvent extends AuthenticationEvent {}

class CheckFirstRunEvent extends AuthenticationEvent {}
