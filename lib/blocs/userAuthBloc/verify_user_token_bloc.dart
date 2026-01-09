import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class VerifyUserTokenBloc extends Bloc<VerifyUserTokenEvent, VerifyUserTokenState> {
  VerifyUserTokenBloc() : super(VerifyUserTokenInitial()) {
    on<VerifyUserToken>((event, emit) async {
      emit(VerifyUserTokenProgress());
      log(" Called VerifyUserTokenBloc");
      try {
        final url = Uri.parse('http://192.168.1.65:1560/auth/verify-token/${event.token}');
        final res = await http.get(url, headers: {'Content-Type': 'application/json', 'Accept': '*/*'});
        // Log response
        log("Status Code: ${res.statusCode}");
        log("Response Body: ${res.body}");
        if (res.statusCode == 200 || res.statusCode == 201) {
          final decodedData = jsonDecode(res.body);
          final valid = decodedData["valid"];
          emit(VerifyUserTokenSuccess(valid: valid));
        } else {
          final errorMessage = jsonDecode(res.body)['message'] ?? "";
          emit(VerifyUserTokenFailure(errorMessage));
        }
      } catch (e) {
        debugPrint("VerifyUserTokenBloc [Catch Exception] >> $e");
        emit(VerifyUserTokenFailure(e.toString()));
      }
    });
  }
}

//states
abstract class VerifyUserTokenState {}

//events
abstract class VerifyUserTokenEvent {}

//states implementation
class VerifyUserTokenInitial extends VerifyUserTokenState {}

class VerifyUserTokenProgress extends VerifyUserTokenState {}

class VerifyUserTokenSuccess extends VerifyUserTokenState {
  final bool valid;
  VerifyUserTokenSuccess({required this.valid});
}

class VerifyUserTokenFailure extends VerifyUserTokenState {
  final dynamic error;
  VerifyUserTokenFailure(this.error);
}

//events implementation
class VerifyUserToken extends VerifyUserTokenEvent {
  VerifyUserToken({required this.token});
  final String token;
}
