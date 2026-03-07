import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

class MyCertificatesPage extends StatelessWidget {
  const MyCertificatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final maxContentWidth = screenWidth > 700 ? 600.0 : double.infinity;

    final certificates = [
      {
        "title": l10n.certificateRoadSignsMastery,
        "date": "12 Jan 2026",
        "status": l10n.certificatesEarned,
        "progress": 1.0,
        "earned": true,
      },
      {
        "title": l10n.certificateTrafficRulesTest,
        "date": "5 Feb 2026",
        "status": l10n.certificatesEarned,
        "progress": 1.0,
        "earned": true,
      },
      {
        "title": l10n.certificateDefensiveDriving,
        "date": l10n.certificatesInProgress,
        "status": l10n.certificatesPending,
        "progress": 0.6,
        "earned": false,
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.certificatesTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.certificatesAchievements,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        ...certificates.map((cert) =>
                            _certificateCard(cert)).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _certificateCard(Map<String, dynamic> cert) {
    final bool isEarned = cert["earned"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isEarned
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isEarned ? Icons.workspace_premium : Icons.pending_actions,
                  color: isEarned
                      ? AppColors.primary
                      : AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  cert["title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                cert["status"],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isEarned
                      ? AppColors.primary
                      : AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          LinearProgressIndicator(
            value: cert["progress"],
            minHeight: 8,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            color: isEarned
                ? AppColors.primary
                : AppColors.warning,
          ),

          const SizedBox(height: 8),

          Text(
            cert["date"],
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}