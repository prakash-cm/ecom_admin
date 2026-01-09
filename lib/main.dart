import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'blocs/userAuthBloc/user_auth_changed_bloc.dart';
import 'blocs/userAuthBloc/user_login_bloc.dart';
import 'blocs/userAuthBloc/user_logout_bloc.dart';
import 'blocs/userAuthBloc/user_registration_bloc.dart';
import 'blocs/userAuthBloc/verify_user_token_bloc.dart';
import 'localDb/hive_config.dart';
import 'wrapper/user_auth_wrapper.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      initializeDateFormatting();
      await AppHiveConfig.init().then((value) {
        runApp(const MyApp());
      });
    },
    (Object error, StackTrace stack) {
      debugPrint("Zoned Error\nerror: $error\nstackTrace: $stack");
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserLoginBloc()),
        BlocProvider(create: (context) => UserSignupBloc()),
        BlocProvider(create: (context) => UserLogoutBloc()),
        BlocProvider(create: (context) => UserAuthChangesBloc()),
        BlocProvider(create: (context) => VerifyUserTokenBloc()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        home: UserAuthWrapper(),
      ),
    );
  }
}
