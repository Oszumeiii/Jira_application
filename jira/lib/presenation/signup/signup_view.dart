import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/presenation/login/login_view.dart';
import 'package:jira/presenation/signup/cubit/signup_cubit.dart';
import 'package:jira/presenation/signup/cubit/signup_state.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPage createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  bool _showPass = true;
  var _nameErr = "Ô này không được để trống";
  var _fnameInvalid = false;
  var _lnameInvalid = false;

  TextEditingController _fNameController = TextEditingController();
  TextEditingController _lNameController = TextEditingController();
  TextEditingController _uNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();

  void validateFirstName(String value) {
    setState(() {
      _fnameInvalid = value.isEmpty;
    });
  }

  void validateLastName(String value) {
    setState(() {
      _lnameInvalid = value.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) {
          return SignUpCubit();
        },
        child: Builder(
          builder: (blocContext) => BlocConsumer<SignUpCubit, SignUpState>(
            listener: (context, state) {
              if (state.isSignUpSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
              } else if (state.errorMessage.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Đăng kí thất bại"),
                    content: Text(state.errorMessage),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          blocContext.read<SignUpCubit>().resetErrorMessage();
                        },
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            },
            builder: (context, state) {
              return Container(
                padding: EdgeInsets.fromLTRB(30, 70, 30, 30),
                constraints: BoxConstraints.expand(),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 13.36),
                        child: Center(
                          child: SizedBox(
                            width: 47.84358596801758,
                            height: 55.63597869873047,
                            child: Image(
                              image: AssetImage("assets/images/JiraLogo.png"),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 26,
                            color: Color(0xff030303),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                        child: Text(
                          "Enter your credentials to continue",
                          style: TextStyle(
                            color: Color(0xff7C7C7C),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 14.45),
                        child: TextField(
                          controller: _fNameController,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff7C7C7C),
                            height: 1.625,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: "First Name",
                            errorText: _fnameInvalid ? _nameErr : null,
                          ),
                          onChanged: validateFirstName,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 14.45),
                        child: TextField(
                          controller: _lNameController,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff7C7C7C),
                            height: 1.625,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: "Last Name",
                            errorText: _lnameInvalid ? _nameErr : null,
                          ),
                          onChanged: validateLastName,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 14.45),
                        child: TextField(
                          controller: _uNameController,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff7C7C7C),
                            height: 1.625,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: "Username",
                            errorText: state.unameErr.isEmpty
                                ? null
                                : state.unameErr,
                          ),
                          onChanged: (value) {
                            context.read<SignUpCubit>().onchangeUname(value);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 13.82),
                        child: TextField(
                          controller: _emailController,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff7C7C7C),
                            height: 1.625,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: "Email",
                            errorText: state.emailErr.isEmpty
                                ? null
                                : state.emailErr,
                          ),
                          onChanged: (value) {
                            context.read<SignUpCubit>().onchangeEmail(value);
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
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.625,
                                fontWeight: FontWeight.w600,
                              ),
                              obscureText: _showPass,
                              decoration: InputDecoration(
                                labelText: "Password",
                                errorText: state.passWordErr.isEmpty
                                    ? null
                                    : state.passWordErr,
                              ),
                              onChanged: (value) {
                                context.read<SignUpCubit>().onchangePassword(
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
                                  image: AssetImage('assets/images/Vector.png'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 19.03),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(height: 1.5),
                            children: [
                              TextSpan(
                                text: "By continuing you agree to our ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff7C7C7C),
                                ),
                              ),
                              TextSpan(
                                text: "Terms of Service and Privacy Policy.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 79, 128, 178),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: SizedBox(
                          width: double.infinity,
                          height: 67,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  (state.emailErr.isEmpty &&
                                      state.passWordErr.isEmpty &&
                                      state.unameErr.isEmpty &&
                                      !_fnameInvalid &&
                                      !_lnameInvalid)
                                  ? Color.fromARGB(255, 79, 128, 178)
                                  : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed:
                                (state.emailErr.isEmpty &&
                                    state.passWordErr.isEmpty &&
                                    state.unameErr.isEmpty &&
                                    !_fnameInvalid &&
                                    !_lnameInvalid)
                                ? () => context.read<SignUpCubit>().SignUp(
                                    _fNameController.text,
                                    _lNameController.text,
                                    _emailController.text,
                                    _passController.text,
                                    _uNameController.text,
                                  )
                                : null,
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xffFFF9FF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: returnSignIn,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 26.25),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Already have an account? ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff7C7C7C),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Sign in",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 79, 128, 178),
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
              );
            },
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

  void returnSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
    );
  }
}
