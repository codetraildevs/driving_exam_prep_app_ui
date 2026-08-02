import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/sign_model.dart';
import '../../data/repositories/signs_repository.dart';

class SignDetailPage extends StatefulWidget {
  final String signId;

  /// Optional repository override so tests can inject a fake and avoid
  /// network calls. Defaults to the real [SignsRepository].
  final SignsRepository? repository;

  const SignDetailPage({required this.signId, this.repository, Key? key})
      : super(key: key);

  @override
  State<SignDetailPage> createState() => _SignDetailPageState();
}

class _SignDetailPageState extends State<SignDetailPage> {
  late final SignsRepository _signsRepo =
      widget.repository ?? SignsRepository();
  late Future<TrafficSignModel?> _signFuture;
  bool _isLearned = false;

  @override
  void initState() {
    super.initState();
    _signFuture = _signsRepo.getSignById(widget.signId);
    _loadLearnedStatus();
  }

  void _loadLearnedStatus() async {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      final isLearned = await _signsRepo.isSignLearned(
        state.user.id,
        widget.signId,
      );
      if (!mounted) return;
      setState(() {
        _isLearned = isLearned;
      });
    }
  }

  void _handleMarkAsLearned() async {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      final messenger = ScaffoldMessenger.of(context);
      final l10n = AppLocalizations.of(context);
      try {
        await _signsRepo.markSignAsLearned(state.user.id, widget.signId);
        if (!mounted) return;
        setState(() {
          _isLearned = true;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.signDetailMarkedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetail(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppLocalizations.of(context).signDetailTitle),
      ),
      body: FutureBuilder<TrafficSignModel?>(
        future: _signFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(AppLocalizations.of(context).signDetailNotFound),
            );
          }

          final sign = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              // Scroll view already applies 24px side padding; only cap the
              // content width so text stays readable on desktop.
              child: ConstrainedContent(
                maxWidth: AppContentWidths.narrow,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFor(Theme.of(context).brightness).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Center(
                        child: Text('🛑', style: TextStyle(fontSize: 80)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(sign.title, style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFor(Theme.of(context).brightness).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sign.category,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primaryFor(Theme.of(context).brightness),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context).signDetailDescription,
                      style: AppTextStyles.heading6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sign.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryFor(Theme.of(context).brightness),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (sign.scenario != null) ...[
                      Text(
                        AppLocalizations.of(context).signDetailScenario,
                        style: AppTextStyles.heading6,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFor(Theme.of(context).brightness).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryFor(Theme.of(context).brightness).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          sign.scenario!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    if (_isLearned)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context).signDetailLearned,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _handleMarkAsLearned,
                        icon: const Icon(Icons.check),
                        label: Text(
                          AppLocalizations.of(context).signDetailMarkAsLearned,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
