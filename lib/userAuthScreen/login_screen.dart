import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/userAuthBloc/user_auth_changed_bloc.dart';
import '../blocs/userAuthBloc/user_login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Map<String, dynamic> loginMap = {};

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserLoginBloc, UserLoginState>(
      listener: (context, uls) {
        if (uls is UserLoginSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful")));
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
        }
        if (uls is UserLoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable Login your account ${uls.error}. Please try again.!")));
        }
      },
      builder: (context, uls) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SizedBox(
                height: 400,
                width: 400,
                child: Card(
                  child: Form(
                    key: loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                        const SizedBox(height: 16),
                        const Text(
                          "Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: uls is UserLoginProgress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required";
                            }
                            if (!value.contains('@')) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          readOnly: uls is UserLoginProgress,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: uls is UserLoginProgress
                                ? null
                                : () {
                                    if (loginFormKey.currentState!.validate()) {
                                      loginMap["email"] = emailController.text.trim();
                                      loginMap["password"] = passwordController.text.trim();
                                      log("loginMap >>>  $loginMap");
                                      context.read<UserLoginBloc>().add(UserLogin(userLoginMap: loginMap));
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(uls is UserLoginProgress ? "Login...." : "Login", style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
