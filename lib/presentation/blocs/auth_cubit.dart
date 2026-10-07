import 'package:connectme_app/services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  // Persisted auth: Firebase restores the session, so we only check it.
  void checkAuthStatus() => emit(
    _authService.currentUser != null ? Authenticated() : Unauthenticated(),
  );

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    final error = await _authService.signIn(email: email, password: password);
    emit(error == null ? Authenticated() : AuthFailure(error));
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final error = await _authService.createAccount(
      fullName: fullName,
      email: email,
      password: password,
    );
    emit(error == null ? Authenticated() : AuthFailure(error));
  }

  Future<void> signOut() async {
    await _authService.signOut();
    emit(Unauthenticated());
  }
}
