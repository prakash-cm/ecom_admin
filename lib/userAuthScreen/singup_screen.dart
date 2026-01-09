import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/userAuthBloc/user_auth_changed_bloc.dart';
import '../blocs/userAuthBloc/user_login_bloc.dart';
import '../blocs/userAuthBloc/user_registration_bloc.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onToggle;

  const SignupScreen({super.key, required this.onToggle});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _signupFormKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserLoginBloc, UserLoginState>(
      listener: (context, uls) {
        if (uls is UserLoginSuccess) {
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
        }
      },
      builder: (context, state) {
        return BlocConsumer<UserSignupBloc, UserSignupState>(
          listener: (context, uss) {
            if (uss is UserSignupSuccess) {
              context.read<UserLoginBloc>().add(UserLogin(userLoginMap: {"email": uss.email, "password": uss.password}));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signup Successful")));
            }
            if (uss is UserSignupFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable Signup your account ${uss.error}. Please try again.!")));
            }
          },
          builder: (context, uss) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: uss is UserSignupProgress
                      ? CircularProgressIndicator()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _signupFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  "Sign Up",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 32),

                                /// FIRST NAME
                                TextFormField(
                                  controller: firstNameController,
                                  decoration: _inputDecoration("First Name"),
                                  validator: (v) => v == null || v.isEmpty ? "First name required" : null,
                                ),
                                const SizedBox(height: 16),

                                /// LAST NAME
                                TextFormField(
                                  controller: lastNameController,
                                  decoration: _inputDecoration("Last Name"),
                                  validator: (v) => v == null || v.isEmpty ? "Last name required" : null,
                                ),
                                const SizedBox(height: 16),

                                /// EMAIL
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _inputDecoration("Email"),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return "Email required";
                                    if (!v.contains('@')) return "Invalid email";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                /// PASSWORD
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: _inputDecoration("Password"),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return "Password required";
                                    if (v.length < 6) return "Minimum 6 characters";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                /// CONFIRM PASSWORD
                                TextFormField(
                                  controller: confirmController,
                                  obscureText: true,
                                  decoration: _inputDecoration("Confirm Password"),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return "Confirm password";
                                    if (v != passwordController.text) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                ElevatedButton(
                                  onPressed: () {
                                    if (_signupFormKey.currentState!.validate()) {
                                      final Map<String, dynamic> signupMap = {};
                                      signupMap["firstName"] = firstNameController.text.trim();
                                      signupMap["lastName"] = lastNameController.text.trim();
                                      signupMap["email"] = emailController.text.trim();
                                      signupMap["password"] = passwordController.text.trim();
                                      signupMap["confirmPassword"] = confirmController.text.trim();
                                      log("signupMap: $signupMap");
                                      context.read<UserSignupBloc>().add(UserSignup(userSignupMap: signupMap));
                                    }
                                  },
                                  child: const Text("Sign Up"),
                                ),
                                const SizedBox(height: 16),

                                TextButton(onPressed: widget.onToggle, child: const Text("Already have an account? Login")),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
