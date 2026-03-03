import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: AppTextStyles.display.copyWith(
                                color: AppColors.textInverse,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Statistics',
                    style: AppTextStyles.heading5,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.assignment,
                          label: 'Tests',
                          value: '12',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.traffic,
                          label: 'Signs',
                          value: '45',
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.trending_up,
                          label: 'Score',
                          value: '78%',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Badges Earned',
                    style: AppTextStyles.heading5,
                  ),
                  const SizedBox(height: 16),
                  _buildBadgesSection(),
                  const SizedBox(height: 40),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(const SignOutEvent());
                      context.go('/landing');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading5.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    final badges = [
      {'emoji': '🌟', 'name': 'Quick Learner'},
      {'emoji': '⚡', 'name': 'Speed Master'},
      {'emoji': '🎯', 'name': 'Accurate'},
      {'emoji': '🔥', 'name': '7 Day Streak'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                badge['emoji'] as String,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                badge['name'] as String,
                style: AppTextStyles.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
