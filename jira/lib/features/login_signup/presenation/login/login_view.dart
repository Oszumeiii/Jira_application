import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jira/features/login_signup/presenation/login/cubit/login_cubit.dart';
import 'package:jira/features/login_signup/presenation/login/cubit/login_state.dart';
import 'package:jira/features/login_signup/presenation/login/forgot_password.dart';
import 'package:jira/features/login_signup/presenation/login/widget/loading_overlay.dart';
import 'package:jira/features/login_signup/presenation/signup/signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginView createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
  bool _showPass = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _navigationToDashboard() {
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Scaffold(
        body: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.isLoginSuccess) {
              _navigationToDashboard();
              context.read<LoginCubit>().resetLoginSuccess();
            } else if (state.errorMessage.isNotEmpty) {
              context.read<LoginCubit>().resetErrorMessage();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 28),
                      SizedBox(width: 10),
                      Text(
                        "Đăng nhập thất bại",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  content: Text(
                    state.errorMessage,
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xff4F80B2),
                      ),
                      child: Text(
                        "OK",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state.isloading,
              message: 'Logging in…',
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(30, 0, 30, 30),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                0,
                                0,
                                64.63,
                              ),
                              child: SizedBox(
                                width: 37.72,
                                height: 42.97,
                                child: Image(
                                  image: AssetImage('assets/images/Logo.png'),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Text(
                              "Log in",
                              style: TextStyle(
                                fontSize: 26,
                                color: Color(0xff181725),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                            child: SizedBox(
                              child: Text(
                                'Enter your emails and password',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff7C7C7C),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                            child: TextField(
                              controller: _emailController,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: "Email",
                                errorText: state.emailErr.isEmpty
                                    ? null
                                    : state.emailErr,
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: Color(0xff4F80B2),
                                ),
                              ),
                              onChanged: (value) {
                                context.read<LoginCubit>().onchangeEmail(value);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                            child: Stack(
                              alignment: AlignmentDirectional.centerEnd,
                              children: [
                                TextField(
                                  controller: _passController,
                                  style: TextStyle(fontSize: 16),
                                  obscureText: !_showPass,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    errorText: state.passWordErr.isEmpty
                                        ? null
                                        : state.passWordErr,
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Color(0xff4F80B2),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    context.read<LoginCubit>().onchangePassword(
                                      value,
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: toggleshowPass,
                                    child: Icon(
                                      _showPass
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Color(0xff7C7C7C),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Color(0xff4F80B2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                            child: SizedBox(
                              width: double.infinity,
                              height: 67,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      (state.emailErr.isEmpty &&
                                          state.passWordErr.isEmpty)
                                      ? Color(0xff4F80B2)
                                      : Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 3,
                                ),
                                onPressed:
                                    (state.emailErr.isEmpty &&
                                        state.passWordErr.isEmpty &&
                                        !state.isloading)
                                    ? () {
                                        context.read<LoginCubit>().login(
                                          _emailController.text,
                                          _passController.text,
                                        );
                                      }
                                    : null,
                                child: state.isloading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        "Log In",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xffFFF9FF),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 205.63),
                            child: Container(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: tosignUp,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Don't have an account? ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff181725),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Sign up",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff4F80B2),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void toggleshowPass() {
    setState(() {
      _showPass = !_showPass;
    });
  }

  void tosignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }
}
