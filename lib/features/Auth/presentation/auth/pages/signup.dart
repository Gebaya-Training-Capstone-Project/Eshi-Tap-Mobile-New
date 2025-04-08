import 'package:eshi_tap/common/widgets/main_tab_view.dart';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/signin.dart';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameCon = TextEditingController();
  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _passwordCon = TextEditingController();
  final TextEditingController _addressCon = TextEditingController();
  final TextEditingController _confirmPasswordCon = TextEditingController();
  final TextEditingController _phoneCon = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _phoneError;
  String? _addressError;

  bool get _isFormValid {
    return _usernameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _phoneError == null &&
        _addressError == null &&
        _usernameCon.text.isNotEmpty &&
        _emailCon.text.isNotEmpty &&
        _passwordCon.text.isNotEmpty &&
        _confirmPasswordCon.text.isNotEmpty &&
        _phoneCon.text.isNotEmpty &&
        _addressCon.text.isNotEmpty;
  }

  void _validateForm() {
    setState(() {
      _usernameError = _usernameCon.text.length < 3 ? 'Username must be at least 3 characters' : null;
      _emailError = !_emailCon.text.contains(RegExp(r'^[^@]+@[^@]+\.[^@]+')) ? 'Enter a valid email' : null;
      _passwordError = _passwordCon.text.length < 6 ? 'Password must be at least 6 characters' : null;
      _confirmPasswordError = _passwordCon.text != _confirmPasswordCon.text ? 'Passwords do not match' : null;
      _phoneError = !_phoneCon.text.startsWith('09') || _phoneCon.text.length != 10 ? 'Enter a valid phone (e.g., 0912345678)' : null;
      _addressError = _addressCon.text.isEmpty ? 'Address cannot be empty' : null;
    });
  }

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _signup(),
                const SizedBox(height: 50),
                _userNameField(),
                const SizedBox(height: 20),
                _emailField(),
                const SizedBox(height: 20),
                _password(),
                const SizedBox(height: 20),
                _confirmPassword(),
                const SizedBox(height: 20),
                _phone(),
                const SizedBox(height: 20),
                _address(),
                const SizedBox(height: 60),
                _createAccountButton(context),
                const SizedBox(height: 20),
                _signinText(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signup() {
    return const Text(
      'Sign Up',
      style: TextStyle(
        color: Color(0xff2A4ECA),
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
    );
  }

  Widget _userNameField() {
    return TextField(
      controller: _usernameCon,
      decoration: InputDecoration(
        hintText: 'Username',
        errorText: _usernameError,
      ),
      onChanged: (_) => _validateForm(),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailCon,
      decoration: InputDecoration(
        hintText: 'Email',
        errorText: _emailError,
      ),
      onChanged: (_) => _validateForm(),
    );
  }

  Widget _password() {
    return TextField(
      controller: _passwordCon,
      decoration: InputDecoration(
        hintText: 'Password',
        errorText: _passwordError,
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      obscureText: !_isPasswordVisible,
      onChanged: (_) => _validateForm(),
    );
  }

  Widget _confirmPassword() {
    return TextField(
      controller: _confirmPasswordCon,
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        errorText: _confirmPasswordError,
        suffixIcon: IconButton(
          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
        ),
      ),
      obscureText: !_isConfirmPasswordVisible,
      onChanged: (_) => _validateForm(),
    );
  }

  Widget _phone() {
    return TextField(
      controller: _phoneCon,
      decoration: InputDecoration(
        hintText: 'Phone',
        errorText: _phoneError,
      ),
      keyboardType: TextInputType.phone,
      onChanged: (_) => _validateForm(),
    );
  }

  Widget _address() {
    return TextField(
      controller: _addressCon,
      decoration: InputDecoration(
        hintText: 'Address',
        errorText: _addressError,
      ),
      onChanged: (_) => _validateForm(),
    );
  }

  Widget _createAccountButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor, // Use AppColor.primary
          ),
          onPressed: (state is AuthLoading || !_isFormValid)
              ? null
              : () {
                  _validateForm();
                  if (_isFormValid) {
                    context.read<AuthBloc>().add(RegisterEvent(
                      username: _usernameCon.text,
                      email: _emailCon.text,
                      password: _passwordCon.text,
                      phone: _phoneCon.text,
                      address: _addressCon.text,
                    ));
                  }
                },
          child: state is AuthLoading
              ? CircularProgressIndicator(color: AppColor.primaryColor)
              : const Text('Create Account'),
        );
      },
    );
  }

  Widget _signinText(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'Do you have an account?',
            style: TextStyle(
              color: Color(0xff3B4054),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: ' Sign In',
            style: TextStyle(
              color: AppColor.primaryColor, // Use AppColor.primary
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SigninPage()),
                );
              },
          ),
        ],
      ),
    );
  }
}