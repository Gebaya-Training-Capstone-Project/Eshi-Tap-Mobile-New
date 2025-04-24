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
      _usernameError = _usernameCon.text.length < 3
          ? 'Username must be at least 3 characters'
          : null;
      _emailError = !_emailCon.text.contains(RegExp(r'^[^@]+@[^@]+\.[^@]+'))
          ? 'Enter a valid email'
          : null;
      _passwordError = _passwordCon.text.length < 6
          ? 'Password must be at least 6 characters'
          : null;
      _confirmPasswordError = _passwordCon.text != _confirmPasswordCon.text
          ? 'Passwords do not match'
          : null;
      _phoneError =
          !_phoneCon.text.startsWith('09') || _phoneCon.text.length != 10
              ? 'Enter a valid phone (e.g., 0912345678)'
              : null;
      _addressError =
          _addressCon.text.isEmpty ? 'Address cannot be empty' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with logo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: AppColor.primaryColor, // Green header background
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 80,
                    ),
                  ),
                ),
                // Form container with rounded corners
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(100),
                      topRight: Radius.circular(120),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Sign Up Title
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'Please sign up to get started',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.subTextColor,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Form Fields
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _userNameField(),
                            const SizedBox(height: 16),
                            _emailField(),
                            const SizedBox(height: 16),
                            _password(),
                            const SizedBox(height: 16),
                            _confirmPassword(),
                            const SizedBox(height: 16),
                            _phone(),
                            const SizedBox(height: 16),
                            _address(),
                            const SizedBox(height: 30),
                            _createAccountButton(context),
                            const SizedBox(height: 20),
                            // Or sign up with Google
                            Row(
                              children: [
                                Expanded(
                                    child:
                                        Divider(color: AppColor.subTextColor)),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    'Or sign up with',
                                    style:
                                        TextStyle(color: AppColor.subTextColor),
                                  ),
                                ),
                                Expanded(
                                    child:
                                        Divider(color: AppColor.subTextColor)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: () {
                                // Add Google Sign-Up logic here
                              },
                              icon: Image.asset(
                                'assets/google_logo.png',
                                height: 24,
                              ),
                              label: Text(
                                'Google',
                                style:
                                    TextStyle(color: AppColor.primaryTextColor),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColor.subTextColor),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12,horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _signinText(context),
                            const SizedBox(height: 20),
                            // Copyright notice
                            Text(
                              '© 2025 ALL RIGHTS RESERVED',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.subTextColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signup() {
    return Text(
      'Sign Up',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColor.primaryTextColor,
      ),
    );
  }

  Widget _userNameField() {
    return TextField(
      controller: _usernameCon,
      decoration: InputDecoration(
        hintText: 'Username',
        hintStyle: TextStyle(color: AppColor.placeholder),
        errorText: _usernameError,
        filled: true,
        fillColor: AppColor.secondoryBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      onChanged: (_) => _validateForm(),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailCon,
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: TextStyle(color: AppColor.placeholder),
        errorText: _emailError,
        filled: true,
        fillColor: AppColor.secondoryBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      onChanged: (_) => _validateForm(),
    );
  }

  Widget _password() {
    return TextField(
      controller: _passwordCon,
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(color: AppColor.placeholder),
        errorText: _passwordError,
        filled: true,
        fillColor: AppColor.secondoryBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColor.subTextColor,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
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
        hintStyle: TextStyle(color: AppColor.placeholder),
        errorText: _confirmPasswordError,
        filled: true,
        fillColor: AppColor.secondoryBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColor.subTextColor,
          ),
          onPressed: () => setState(
              () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
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
        hintStyle: TextStyle(color: AppColor.placeholder),
        errorText: _phoneError,
        filled: true,
        fillColor: AppColor.secondoryBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        hintStyle: TextStyle(color: AppColor.placeholder),
        errorText: _addressError,
        filled: true,
        fillColor: AppColor.secondoryBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      onChanged: (_) => _validateForm(),
    );
  }

  Widget _createAccountButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor, // Green button
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
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
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _signinText(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Do you have an account? ',
            style: TextStyle(
              color: AppColor.subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: 'Sign In',
            style: TextStyle(
              color: AppColor.secondoryColor, // Green link
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
