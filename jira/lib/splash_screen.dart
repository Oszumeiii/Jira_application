import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/core/injection.dart';
import 'package:jira/features/dash_board/projects/presentation/cubit/project_cubit.dart';
import 'package:jira/features/dash_board/presentation/dash_board.dart';
import 'package:jira/features/login_signup/domain/cubit/AuthCubit.dart';
import 'package:jira/features/login_signup/presenation/onboarding/onboarding_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // bool _showSplash = true;

  // @override
  // void initState() {
  //   super.initState();
  //   // Giữ splash 2 giây
  //   Future.delayed(const Duration(seconds: 5), () {
  //     if (mounted) {
  //       setState(() {
  //         _showSplash = false;
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // if (_showSplash) {
    //   return _buildSplashUI();
    // }

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState.isLoggedIn) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ProjectCubit>(
                create: (_) => getIt<ProjectCubit>()..loadProjects(),
              ),
            ],
            child: const DashboardScreen(),
          );
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }

  // Widget _buildSplashUI() {
  //   return Scaffold(
  //     backgroundColor: const Color.fromARGB(255, 2, 60, 147),
  //     body: Center(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           SizedBox(
  //             height: 99,
  //             child: Image.asset("assets/images/Logo2.png", fit: BoxFit.contain),
  //           ),
  //           const SizedBox(width: 10),
  //           const Text(
  //             "Jira",
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 45,
  //               fontWeight: FontWeight.bold,
  //               letterSpacing: 1.5,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
