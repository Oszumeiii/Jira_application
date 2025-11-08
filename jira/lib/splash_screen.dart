import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/domain/cubit/AuthCubit.dart';

import 'package:jira/presenation/onboarding/onboarding_view.dart';
import 'package:jira/presenation/screen/dash_board.dart';

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
