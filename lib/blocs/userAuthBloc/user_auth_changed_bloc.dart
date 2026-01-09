import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class UserAuthChangesBloc extends Bloc<UserAuthChangesEvent, UserAuthChangesState> {
  UserAuthChangesBloc() : super(UserAuthChangesInitial()) {
    on<StartUserChangeListener>((event, emit) async {
      if (kDebugMode) debugPrint('Called UserAuthChangesBloc');
      emit(UserAuthChangesProgress());
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedData != null && savedData.token != null && savedData.validTill != null) {
        final rawDate = savedData.validTill!;
        final formatter = DateFormat("dd:MM:yyyy HH:mm:ss");
        final expiry = formatter.parse(rawDate);
        final now = DateTime.now();
        if (now.isBefore(expiry)) {
          emit(UserAuthChangesSuccess(savedUserAuth: savedData));
        } else {
          await SaveTokenBox.loginTokenBox.clearLoginToken();
          emit(UserAuthChangesFailure());
        }
      } else {
        emit(UserAuthChangesFailure());
      }
    });
  }
}

//states
abstract class UserAuthChangesState {}

//events
abstract class UserAuthChangesEvent {}

//states implementation
class UserAuthChangesInitial extends UserAuthChangesState {}

class UserAuthChangesProgress extends UserAuthChangesState {}

class UserAuthChangesSuccess extends UserAuthChangesState {
  UserAuthChangesSuccess({required this.savedUserAuth});
  final SaveLoginTokenModel? savedUserAuth;
}

class UserAuthChangesFailure extends UserAuthChangesState {}

//events implementation
class StartUserChangeListener extends UserAuthChangesEvent {}
