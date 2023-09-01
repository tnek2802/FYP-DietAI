import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';

class User {
  String email;

  String firstName;

  String lastName;

  String userID;

  String profilePictureURL;

  String appIdentifier;

  int age;

  String gender;

  double weight;

  double height;
  
  String medicalHistory;

  String foodPreferences;

  User(
      {this.email = '',
      this.firstName = '',
      this.lastName = '',
      this.userID = '',
      this.profilePictureURL = '',
      this.age = 18,
      this.gender = '',
      this.weight = 50,
      this.height = 170,
      this.medicalHistory = '',
      this.foodPreferences = ''})
      : appIdentifier =
            'Flutter Login Screen ${kIsWeb ? 'Web' : Platform.operatingSystem}';

  String fullName() => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      email: parsedJson['email'] ?? '',
      firstName: parsedJson['firstName'] ?? '',
      lastName: parsedJson['lastName'] ?? '',
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
      profilePictureURL: parsedJson['profilePictureURL'] ?? '',
      age: parsedJson['age'] is int ? parsedJson['age'] as int : int.tryParse(parsedJson['age'].toString()) ?? 0,
      gender: parsedJson['gender'] ?? '',
      weight: parsedJson['weight'] is double ? parsedJson['weight'] as double : double.tryParse(parsedJson['weight'].toString()) ?? 0.0,
      height: parsedJson['height'] is double ? parsedJson['height'] as double : double.tryParse(parsedJson['height'].toString()) ?? 0.0,
      medicalHistory: parsedJson['medicalHistory'] ?? '',
      foodPreferences: parsedJson['foodPreferences'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'id': userID,
      'profilePictureURL': profilePictureURL,
      'appIdentifier': appIdentifier,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'medicalHistory': medicalHistory,
      'foodPreferences': foodPreferences
    };
  }
}
