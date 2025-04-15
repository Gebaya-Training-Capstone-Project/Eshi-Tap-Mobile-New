import 'package:eshi_tap/common/widgets/main_tab_view.dart';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/signin.dart';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:eshi_tap/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuthEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor, // Replace with AppColor.primaryColor when defined
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          Future.delayed(const Duration(seconds: 2), () {
            // if (state is AuthAuthenticated) {
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (context) => const MainTabView()),
            //   );
            // } else 
            if (state is AuthUnauthenticated || state is AuthError) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OnboardingPage()),
              );
            }
          });
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 250,
                height: 200,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}