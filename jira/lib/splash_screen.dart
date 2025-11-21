import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/core/injection.dart';
import 'package:jira/features/dash_board/projects/presentation/cubit/project_cubit.dart';
import 'package:jira/features/dash_board/presentation/dash_board.dart';
import 'package:jira/features/login_signup/domain/cubit/AuthCubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, bool>(
      builder: (context, isLoggedIn) {
          // Wrap DashboardScreen với ProjectCubit
        if (isLoggedIn) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ProjectCubit>(
                create: (_) => getIt<ProjectCubit>()
              ),
            ],
            child: const DashboardScreen(),
          );
        }
        else {
        
         return MultiBlocProvider(
            providers: [
              BlocProvider<ProjectCubit>(
                create: (_) => getIt<ProjectCubit>()
              ),
            ],
            child: const DashboardScreen(),
          );
        }
        } 
      
    );
  }
}
