import 'package:connect_me_community_app/injection.dart';
import 'package:connect_me_community_app/presentation/blocs/auth_cubit.dart';
import 'package:connect_me_community_app/presentation/screens/home_screen.dart';
import 'package:connect_me_community_app/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>()..checkAuthStatus(), //creates an authcubit object via SL(sl) and returns the cubit to emit the status
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ConnectMe Community App',
        home: BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (_, current) =>
              current is Authenticated || current is Unauthenticated,
          builder: (context, state) =>
              state is Authenticated ? const HomeScreen() : const LoginScreen(),
        ),
      ),
    );
  }
}