import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../token/app_string_constants.dart';
import 'login_credentials_model.dart';

class LoginCredentialsBox with AppStringConstants {
  static const String hiveBoxKey = AppStringConstants.hiveBoxKey;
  static const String loginCredentialsBoxKey = AppStringConstants.credentialsBoxKey;
  late Box _loginCredentialsBox;
  LoginCredentialsBox._() {
    _loginCredentialsBox = Hive.box(hiveBoxKey);
  }
  static final LoginCredentialsBox _singleton = LoginCredentialsBox._();
  factory LoginCredentialsBox() => _singleton;

  ///for public use
  static LoginCredentialsBox get loginCredentialsBox => _singleton;

  ///save data to db
  set saveLoginCredentials(LoginCredentialsModel value) {
    _loginCredentialsBox.put(loginCredentialsBoxKey, value).catchError(
      (error, stack) {
        if (kDebugMode) log("Hive credentials saving error >>, $error  $stack");
      },
    );
  }

  ///fetch data from db
  LoginCredentialsModel? get fetchLoginCredentials {
    late LoginCredentialsModel? value;
    try {
      value = _loginCredentialsBox.get(loginCredentialsBoxKey);
      return value;
    } catch (e) {
      if (kDebugMode) log("Hive credentials fetching error >> >>, $e");
      return value;
    }
  }

  Future<void> clearLoginCredentials() async {
    try {
      await _loginCredentialsBox.clear();
    } catch (e) {
      if (kDebugMode) debugPrint("Hive credentials clearing error >>, $e");
    }
  }
}
