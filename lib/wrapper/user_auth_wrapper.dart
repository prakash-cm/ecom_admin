import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/mainApp/main_screen.dart';
import '../blocs/userAuthBloc/user_auth_changed_bloc.dart';
import '../blocs/userAuthBloc/verify_user_token_bloc.dart';
import '../userAuthScreen/login_screen.dart';

class UserAuthWrapper extends StatefulWidget {
  const UserAuthWrapper({super.key});

  @override
  State<UserAuthWrapper> createState() => _UserAuthWrapperState();
}

class _UserAuthWrapperState extends State<UserAuthWrapper> {
  @override
  void initState() {
    context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, ucs) {
        if (ucs is UserAuthChangesSuccess) {
          context.read<VerifyUserTokenBloc>().add(VerifyUserToken(token: ucs.savedUserAuth!.token!));
        }
        return BlocBuilder<VerifyUserTokenBloc, VerifyUserTokenState>(
          builder: (context, vts) {
            if (vts is VerifyUserTokenSuccess && vts.valid == true) {
              return MainScreen();
            } else {
              return LoginScreen();
            }
          },
        );
      },
    );
  }
}
