import '../../data/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}

class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}
