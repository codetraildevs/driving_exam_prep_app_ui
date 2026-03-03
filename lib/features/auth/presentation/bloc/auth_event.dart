abstract class AuthEvent {
  const AuthEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const SignUpEvent({
    required this.name,
    required this.email,
    required this.password,
  });
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({
    required this.email,
    required this.password,
  });
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class ResetPasswordEvent extends AuthEvent {
  final String email;

  const ResetPasswordEvent({required this.email});
}
