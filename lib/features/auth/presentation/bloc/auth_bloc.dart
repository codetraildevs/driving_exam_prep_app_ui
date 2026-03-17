import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/network/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

/// Returns a user-friendly error message; hides raw exceptions.
String _friendlyError(Object e) {
  final msg = e.toString().toLowerCase();
  if (msg.contains('socketexception') ||
      msg.contains('failed host lookup') ||
      msg.contains('connection refused') ||
      msg.contains('network is unreachable') ||
      msg.contains('timed out') ||
      msg.contains('handshake') ||
      msg.contains('clientexception')) {
    return 'NETWORK_ERROR';
  }
  if (e is ApiException) {
    return e.message;
  }
  return 'GENERIC_ERROR';
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      if (await _authRepository.isAuthenticated()) {
        final userId = await _authRepository.getCurrentUserId();
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
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUp(
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        preferredLanguage: event.preferredLanguage,
      );

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Failed to create account'));
      }
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signIn(
        phoneNumber: event.phoneNumber,
      );

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Failed to sign in'));
      }
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
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
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.deleteAccount(event.userId);
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }
}
