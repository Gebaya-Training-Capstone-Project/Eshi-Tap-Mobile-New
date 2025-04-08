import 'package:eshi_tap/common/widgets/main_tab_view.dart';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/signup.dart';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _usernameCon = TextEditingController();
  final TextEditingController _passwordCon = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainTabView()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 100, right: 16, left: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _signin(),
              const SizedBox(height: 50),
              _usernameField(),
              const SizedBox(height: 20),
              _password(),
              const SizedBox(height: 60),
              _loginButton(context),
              const SizedBox(height: 20),
              _signupText(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signin() {
    return const Text(
      'Sign In',
      style: TextStyle(
        color: Color(0xff2A4ECA),
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
    );
  }

  Widget _usernameField() {
    return TextField(
      controller: _usernameCon,
      decoration: const InputDecoration(hintText: 'Username'),
    );
  }

  Widget _password() {
    return TextField(
      controller: _passwordCon,
      decoration: InputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      obscureText: !_isPasswordVisible,
    );
  }

  Widget _loginButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor, // Use AppColor.primary
          ),
          onPressed: state is AuthLoading
              ? null
              : () {
                  context.read<AuthBloc>().add(LoginEvent(
                    _usernameCon.text,
                    _passwordCon.text,
                  ));
                },
          child: state is AuthLoading
              ? CircularProgressIndicator(color: AppColor.primaryColor) // Use AppColor.primary
              : const Text('Login'),
        );
      },
    );
  }

  Widget _signupText(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: "Don't you have an account?",
            style: TextStyle(
              color: Color(0xff3B4054),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: ' Sign Up',
            style: TextStyle(
              color: AppColor.primaryColor, // Use AppColor.primary
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
          ),
        ],
      ),
    );
  }
}