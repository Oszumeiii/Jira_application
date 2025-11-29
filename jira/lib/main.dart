import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jira/core/api_client.dart';
import 'package:jira/core/injection.dart';
import 'package:jira/features/dash_board/presentation/profile/profile.dart';
import 'package:jira/features/dash_board/projects/presentation/cubit/project_cubit.dart';
import 'package:jira/features/login_signup/domain/cubit/AuthCubit.dart';
import 'package:jira/firebase_options.dart';
import 'package:jira/features/login_signup/presenation/login/login_view.dart';
import 'package:jira/features/dash_board/presentation/dash_board.dart';
import 'package:jira/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ApiClient.setup();
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => LoginView()),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<ProjectCubit>(create: (_) => getIt<ProjectCubit>()),
            ],
            child: const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        // GoRoute(path: '/dashboard/home', builder: (context, state) => const HomeTab()),
        // GoRoute(path: '/dashboard/projects', builder: (context, state) => const ProjectsTab()),
        // GoRoute(path: '/dashboard/tasks', builder: (context, state) => const SplashScreen()),
      ],
    );
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AuthCubit())],
      child: MaterialApp.router(
        title: 'Jira App',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
