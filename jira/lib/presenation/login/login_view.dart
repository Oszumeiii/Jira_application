import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/presenation/login/cubit/login_cubit.dart';
import 'package:jira/presenation/login/cubit/login_state.dart';
import 'package:jira/presenation/screen/dash_board.dart';
import 'package:jira/presenation/signup/signup_view.dart';

class LoginView extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    // ✅ Thêm BlocProvider trực tiếp vào đây
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Container(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 30),
                color: Colors.white,
                child: BlocConsumer<LoginCubit, LoginState>(
                  listener: (context, state) {
                    if (state.isLoginSuccess) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(),
                        ),
                      );
                      context.read<LoginCubit>().resetLoginSuccess();
                    } else if (state.errorMessage.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Đăng nhập thất bại"),
                          content: Text(state.errorMessage),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.read<LoginCubit>().resetErrorMessage();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 64.63),
                            child: SizedBox(
                              width: 37.72,
                              height: 42.97,
                              child: Image(
                                image: AssetImage('assets/images/JiraLogo.png'),
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
                                ),
                                onChanged: (value) {
                                  context.read<LoginCubit>().onchangePassword(
                                    value,
                                  );
                                },
                              ),
                              GestureDetector(
                                onTap: toggleshowPass,
                                child: SizedBox(
                                  width: 19.93,
                                  height: 18.92,
                                  child: Image(
                                    image: _showPass
                                        ? AssetImage('assets/images/Vector.png')
                                        : AssetImage(
                                            "assets/images/eyehide.png",
                                          ),
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
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Color(0xff7C7C7C)),
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
                                    ? Color.fromARGB(255, 79, 128, 178)
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed:
                                  (state.emailErr.isEmpty &&
                                      state.passWordErr.isEmpty)
                                  ? () {
                                      context.read<LoginCubit>().login(
                                        _emailController.text,
                                        _passController.text,
                                      );
                                    }
                                  : null,
                              child: Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xffFFF9FF),
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
                                        color: Color.fromARGB(
                                          255,
                                          79,
                                          128,
                                          178,
                                        ),
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
                    );
                  },
                ),
              ),
            ),
          ),
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
