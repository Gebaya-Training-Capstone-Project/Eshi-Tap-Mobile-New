import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:eshi_tap/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eshi_tap/injection_container.dart' as di; // Import the dependency injection container


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashPage(), // Use SplashScreen as the initial screen
        // home: MainTabView(),
      ),
    );
  }
}