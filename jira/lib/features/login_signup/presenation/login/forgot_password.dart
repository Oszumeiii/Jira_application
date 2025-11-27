import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/login_signup/presenation/login/cubit/forgot_password_cubit.dart';
import 'package:jira/features/login_signup/presenation/login/cubit/forgot_password_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(),
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
                child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
                  listener: (context, state) {
                    if (state.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "A password reset link has been sent to ${state.email}",
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.read<ForgotPasswordCubit>().reset();
                    } else if (state.errorMessage.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                      context.read<ForgotPasswordCubit>().resetError();
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
                                image: AssetImage('assets/images/Logo.png'),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(
                              fontSize: 26,
                              color: Color(0xff181725),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                          child: Text(
                            'Enter your email address to receive a password reset link.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff7C7C7C),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                          child: TextField(
                            controller: _emailController,
                            style: TextStyle(fontSize: 16),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              errorText: state.emailErr.isEmpty
                                  ? null
                                  : state.emailErr,
                            ),
                            onChanged: (value) {
                              context
                                  .read<ForgotPasswordCubit>()
                                  .onEmailChanged(value);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                          child: SizedBox(
                            width: double.infinity,
                            height: 67,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.emailErr.isEmpty
                                    ? Color.fromARGB(255, 79, 128, 178)
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: state.emailErr.isEmpty
                                  ? () {
                                      context
                                          .read<ForgotPasswordCubit>()
                                          .sendResetEmail(
                                            _emailController.text,
                                          );
                                    }
                                  : null,
                              child: state.isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Send Reset Link",
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
                          child: Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                "Back to Login",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 79, 128, 178),
                                  fontWeight: FontWeight.w600,
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
}
