import 'package:connect_me_community_app/presentation/blocs/auth_cubit.dart';
import 'package:connect_me_community_app/presentation/screens/sign_up_screen.dart';
import 'package:connect_me_community_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validate the form, then hand the work to the cubit.
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthCubit>().state is AuthLoading;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<AuthCubit, AuthState>(
      // Only job here: show the error message if login failed.
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login Screen'), centerTitle: true),
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              // Purple background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5151C6), Color(0xFF888BF4)],
                  ),
                ),
              ),
              // White rounded sheet, 67% of the screen height
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.67,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(35)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 35, 20, 30),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _fieldStyle('Email', 'Enter your Email'),
                          validator: AuthService.validateEmail,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration:
                              _fieldStyle('Password', 'Enter your Password')
                                  .copyWith(
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscureText = !_obscureText),
                              icon: Icon(_obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                          ),
                          validator: AuthService.validatePassword,
                        ),
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5151C6), Color(0xFF888BF4)],
                            ),
                          ),
                          child: ElevatedButton(
                            // Disabled while waiting for Firebase
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('LOG IN',
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an Account?"),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              ),
                              child: const Text('SIGN UP'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Same look for every field, defined once.
  InputDecoration _fieldStyle(String label, String hint) {
    return InputDecoration(
      filled: true,
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }
}