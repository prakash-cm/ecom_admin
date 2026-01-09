import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class UserLoginBloc extends Bloc<UserLoginEvent, UserLoginState> {
  UserLoginBloc() : super(UserLoginInitial()) {
    on<UserLogin>((event, emit) async {
      emit(UserLoginProgress());
      log(" Called UserLoginBloc");
      try {
        // Your API URL
        final url = Uri.parse('http://192.168.1.65:1560/auth/login');
        // POST request
        final res = await http.post(url, headers: {'Content-Type': 'application/json', 'Accept': '*/*'}, body: jsonEncode(event.userLoginMap));
        if (res.statusCode == 200 || res.statusCode == 201) {
          final decoded = jsonDecode(res.body);
          log("User Login Data >> ${decoded.toString()}");
          final role = decoded["role"];
          final userName = decoded["userName"];
          if (role.toString().contains('superAdmin')) {
            SaveTokenBox.loginTokenBox.saveLoginToken = SaveLoginTokenModel(
              token: decoded["token"],
              refreshToken: decoded["refreshToken"],
              validTill: decoded["validTill"],
              savedAt: DateTime.now(),
              userId: decoded["userId"].toString(),
              role: role,
              userName: userName,
            );
            emit(UserLoginSuccess());
          } else {
            emit(UserLoginFailure("Login failed! user can't allow to login"));
          }
        } else {
          final errorMessage = jsonDecode(res.body)['message'] ?? "Unauthorized";
          emit(UserLoginFailure(errorMessage));
        }
      } catch (e) {
        log("UserLoginBloc [Catch Exception] >> $e");
        emit(UserLoginFailure(e.toString()));
      }
    });
  }
}

//states
abstract class UserLoginState {}

//events
abstract class UserLoginEvent {}

//states implementation
class UserLoginInitial extends UserLoginState {}

class UserLoginProgress extends UserLoginState {}

class UserLoginSuccess extends UserLoginState {}

class UserLoginFailure extends UserLoginState {
  final dynamic error;
  UserLoginFailure(this.error);
}

//events implementation
class UserLogin extends UserLoginEvent {
  UserLogin({required this.userLoginMap});
  final Map<String, dynamic> userLoginMap;
}
