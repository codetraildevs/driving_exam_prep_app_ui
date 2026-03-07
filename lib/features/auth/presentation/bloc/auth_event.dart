abstract class AuthEvent {
  const AuthEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class SignUpEvent extends AuthEvent {
  final String fullName;
  final String phoneNumber;

  const SignUpEvent({
    required this.fullName,
    required this.phoneNumber,
  });
}

class SignInEvent extends AuthEvent {
  final String phoneNumber;

  const SignInEvent({
    required this.phoneNumber,
  });
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}
