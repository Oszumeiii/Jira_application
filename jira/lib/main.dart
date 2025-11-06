import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jira/domain/cubit/AuthCubit.dart';
import 'package:jira/firebase_options.dart';
import 'package:jira/presenation/screen/profile.dart';
import 'package:jira/presenation/screen/project_page.dart';
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
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(), 
        ),

        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectPage(), 
        ),

        GoRoute(
          path: '/tasks',
          builder: (context, state) => const SplashScreen(), 
        ),

        // GoRoute(
        //   path: '/main',
        //   builder: (context, state) => const MainScreen(),
        // ),
        // GoRoute(
        //   path: '/profile',
        //   builder: (context, state) => const ProfileScreen(),
        // ),
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
