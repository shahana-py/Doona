import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../constants/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.pop(context);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo/Icon
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Welcome text
                  const Center(
                    child: Text(
                      "Let's get started!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Create your account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Email field
                  CustomTextField(
                    label: AppStrings.email,
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password field
                  CustomTextField(
                    label: AppStrings.password,
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password field
                  CustomTextField(
                    label: 'Confirm Password',
                    hintText: 'Confirm your password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Register button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: AppStrings.register,
                        onPressed: _register,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const Spacer(),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}