import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jira/domain/cubit/AuthCubit.dart';
import 'package:jira/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/splash_screen.dart';
void main() async {
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
    return  MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: MaterialApp(
        title: 'Jira App',
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
