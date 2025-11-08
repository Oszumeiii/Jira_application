import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jira/domain/cubit/AuthCubit.dart';
import 'package:jira/firebase_options.dart';
import 'package:jira/presenation/login/login_view.dart';
import 'package:jira/presenation/screen/dashboard/dash_board.dart';
import 'package:jira/presenation/screen/dashboard/home_tab.dart';
import 'package:jira/presenation/screen/dashboard/profile.dart';
import 'package:jira/presenation/screen/dashboard/projects_tab.dart';
import 'package:jira/splash_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => LoginView()),
        GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        // GoRoute(path: '/dashboard/home', builder: (context, state) => const HomeTab()),
        // GoRoute(path: '/dashboard/projects', builder: (context, state) => const ProjectsTab()),
        // GoRoute(path: '/dashboard/tasks', builder: (context, state) => const SplashScreen()),
      ],
);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: MaterialApp.router(
        title: 'Jira App',
        debugShowCheckedModeBanner: false,
        routerConfig: _router, 
      ),
    );
  }
}
