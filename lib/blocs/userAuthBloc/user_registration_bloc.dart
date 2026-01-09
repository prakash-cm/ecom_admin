import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class UserSignupBloc extends Bloc<UserSignupEvent, UserSignupState> {
  UserSignupBloc() : super(UserSignupInitial()) {
    on<UserSignup>((event, emit) async {
      emit(UserSignupProgress());
      log(" Called UserSignupBloc");
      try {
        // Your API URL
        final url = Uri.parse('http://192.168.1.65:1560/manageUser/createUser');

        // POST request
        final res = await http.post(url, headers: {'Content-Type': 'application/json', 'Accept': '*/*'}, body: jsonEncode(event.userSignupMap));
        // Log response
        log("Status Code: ${res.statusCode}");
        log("Response Body: ${res.body}");

        if (res.statusCode == 200 || res.statusCode == 201) {
          final decodedData = jsonDecode(res.body)['user'];
          final email = decodedData["email"];
          emit(UserSignupSuccess(email: email, password: event.userSignupMap["password"]));
        } else {
          final errorMessage = jsonDecode(res.body)['message'] ?? "";
          emit(UserSignupFailure(errorMessage));
        }
      } catch (e) {
        debugPrint("UserSignupBloc [Catch Exception] >> $e");
        emit(UserSignupFailure(e.toString()));
      }
    });
  }
}

//states
abstract class UserSignupState {}

//events
abstract class UserSignupEvent {}

//states implementation
class UserSignupInitial extends UserSignupState {}

class UserSignupProgress extends UserSignupState {}

class UserSignupSuccess extends UserSignupState {
  final String email;
  final String password;
  UserSignupSuccess({required this.email, required this.password});
}

class UserSignupFailure extends UserSignupState {
  final dynamic error;
  UserSignupFailure(this.error);
}

//events implementation
class UserSignup extends UserSignupEvent {
  UserSignup({required this.userSignupMap});
  final Map<String, dynamic> userSignupMap;
}
