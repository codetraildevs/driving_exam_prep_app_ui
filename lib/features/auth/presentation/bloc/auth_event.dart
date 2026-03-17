abstract class AuthEvent {
  const AuthEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class SignUpEvent extends AuthEvent {
  final String fullName;
  final String phoneNumber;
  final String preferredLanguage;

  const SignUpEvent({
    required this.fullName,
    required this.phoneNumber,
    this.preferredLanguage = 'en',
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

class DeleteAccountEvent extends AuthEvent {
  final String userId;
  const DeleteAccountEvent({required this.userId});
}
