import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_notifier.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isRecoveryDialogOpen = false;
  // bool _agreedToTerms = false;

  final String supportNumber1 = "+250788659575";
  final String supportDisplay1 = "+250 788 659 575";
  final String supportNumber2 = "+250728877442";
  final String supportDisplay2 = "+250 728 877 442";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static final _nameRegex = RegExp(r"^[a-zA-Z\u00C0-\u024F\s'-]+$");
  static final _rwandaPhoneRegex = RegExp(r'^(\+?250|0)?7[2389]\d{7}$');
  static final _intlPhoneRegex = RegExp(r'^\+[1-9]\d{6,14}$');

  void _handleRegister() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.replaceAll(RegExp(r'[\s\-]'), '');
    final l10n = AppLocalizations.of(context);

    if (name.isEmpty || phone.isEmpty) {
      _showError(l10n.registerFillAllFields);
      return;
    }

    if (!_nameRegex.hasMatch(name)) {
      _showError(l10n.registerInvalidName);
      return;
    }

    if (!_rwandaPhoneRegex.hasMatch(phone) && !_intlPhoneRegex.hasMatch(phone)) {
      _showError(l10n.registerInvalidPhone);
      return;
    }

    // if (!_agreedToTerms) {
    //   _showError(l10n.registerAgreeTerms);
    //   return;
    // }

    final container = ProviderScope.containerOf(context, listen: false);
    final langCode = container.read(localeProvider).effectiveLocale.languageCode;
    context.read<AuthBloc>().add(
      SignUpEvent(
        fullName: name,
        phoneNumber: phone,
        preferredLanguage: langCode,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  ({String? code, String message}) _parseAuthError(String raw) {
    final idx = raw.indexOf('|');
    if (idx <= 0) return (code: null, message: raw);
    return (
      code: raw.substring(0, idx).trim(),
      message: raw.substring(idx + 1).trim(),
    );
  }

  Future<void> _promptRecoveryFromRegister() async {
    if (_isRecoveryDialogOpen || !mounted) return;
    final phone = _phoneController.text.replaceAll(RegExp(r'[\s\-]'), '');
    final name = _nameController.text.trim();
    if (phone.isEmpty || name.length < 2) {
      _showError('Enter your full name and phone number to recover this account.');
      return;
    }

    _isRecoveryDialogOpen = true;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Move account to this device'),
            content: const Text(
              'This phone number already exists on another device. Do you want to move that account to this phone?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Move account'),
              ),
            ],
          );
        },
      );

      if (confirmed == true && mounted) {
        context.read<AuthBloc>().add(
          RebindDeviceEvent(
            fullName: name,
            phoneNumber: phone,
          ),
        );
      }
    } finally {
      _isRecoveryDialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final isAdmin = state.user.role == 'ADMIN' || state.user.role == 'MANAGER';
            context.go(isAdmin ? '/admin' : '/home');
          } else if (state is AuthError) {
            final l10nLocal = AppLocalizations.of(context);
            final parsed = _parseAuthError(state.message);
            final msg = parsed.message == 'NETWORK_ERROR'
                ? l10nLocal.errorNetwork
                : parsed.message == 'GENERIC_ERROR'
                    ? l10nLocal.commonError
                    : parsed.message;
            _showError(msg);
            if (parsed.code == 'PHONE_BOUND_TO_OTHER_DEVICE' ||
                parsed.code == 'DEVICE_ALREADY_IN_USE') {
              _promptRecoveryFromRegister();
            }
          }
        },
        child: Column(
          children: [
            // Curved gradient header
            ClipPath(
              clipper: _CurvedHeaderClipper(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 32,
                  bottom: 40,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradientFor(Theme.of(context).brightness),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.authAppName,
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.authSubtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable body
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        const SizedBox(height: 24),

                    // Registration Title
                    Text(
                      l10n.registerTitle,
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.neutral900,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      l10n.registerSubtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.neutral600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Support line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '${l10n.authNeedHelp} ',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _callNumber(supportNumber1),
                          child: Text(
                            supportDisplay1.replaceAll(' ', ''),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryFor(Theme.of(context).brightness),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          ' / ',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral400),
                        ),
                        GestureDetector(
                          onTap: () => _callNumber(supportNumber2),
                          child: Text(
                            supportDisplay2.replaceAll(' ', ''),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryFor(Theme.of(context).brightness),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Full Name Field
                    TextField(
                      controller: _nameController,
                      style: AppTextStyles.bodyLarge,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\u00C0-\u024F\s'-]")),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.authFullName,
                        hintText: l10n.authFullNameHint,
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primaryFor(Theme.of(context).brightness),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Phone Field
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: AppTextStyles.bodyLarge,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]')),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.authPhoneNumber,
                        hintText: l10n.authPhoneHint,
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primaryFor(Theme.of(context).brightness),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    // const SizedBox(height: 20),

                    // Terms Checkbox
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Checkbox(
                    //       value: _agreedToTerms,
                    //       activeColor: AppColors.primaryFor(Theme.of(context).brightness),
                    //       onChanged: (value) {
                    //         setState(() {
                    //           _agreedToTerms = value ?? false;
                    //         });
                    //       },
                    //     ),
                    //     Expanded(
                    //       child: Text(
                    //         l10n.registerTerms,
                    //         style: AppTextStyles.bodyMedium.copyWith(
                    //           color: AppColors.neutral600,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    const SizedBox(height: 24),

                    // Register Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryFor(Theme.of(context).brightness),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: AppColors.textInverse,
                                  )
                                : Text(l10n.registerSignUp),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.registerHaveAccount,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            l10n.registerLogIn,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryFor(Theme.of(context).brightness),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    Text(
                      l10n.authSecureTag,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
  ],       ),
      ),
      ),
    );
  }
}

/// Clips the bottom edge of a container into a smooth downward curve.
class _CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 40)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}