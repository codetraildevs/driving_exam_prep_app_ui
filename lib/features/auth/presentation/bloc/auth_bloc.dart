import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      if (_authRepository.isAuthenticated()) {
        final userId = _authRepository.getCurrentUserId();
        if (userId != null) {
          final user = await _authRepository.fetchUserProfile(userId);
          if (user != null) {
            emit(AuthAuthenticated(user));
          } else {
            emit(const AuthUnauthenticated());
          }
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Failed to create account'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Failed to sign in'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.resetPassword(email: event.email);
      emit(const PasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
