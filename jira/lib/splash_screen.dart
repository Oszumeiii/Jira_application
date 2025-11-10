import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/presentation/dash_board.dart';
import 'package:jira/features/login_signup/domain/cubit/AuthCubit.dart';
import 'package:jira/features/login_signup/presenation/onboarding/onboarding_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, bool>(
      builder: (context, isLoggedIn) {
        if (isLoggedIn) {
          return const DashboardScreen();
        } else {
          return OnboardingScreen();
        }
      },
    );
  }
}
