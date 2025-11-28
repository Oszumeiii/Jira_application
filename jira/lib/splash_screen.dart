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
  late Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    // Delay 2 giây rồi trả về trạng thái đăng nhập
    _initFuture = Future.delayed(const Duration(seconds: 2), () {
      return context.read<AuthCubit>().state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildSplashUI();
        }

        final isLoggedIn = snapshot.data ?? false;

        if (isLoggedIn) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ProjectCubit>(create: (_) => getIt<ProjectCubit>()),
            ],
            child: const DashboardScreen(),
          );
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }

  Widget _buildSplashUI() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 60, 147),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 99,
              child: Image.asset(
                "assets/images/Logo2.png",
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Jira",
              style: TextStyle(
                color: Colors.white,
                fontSize: 45,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
