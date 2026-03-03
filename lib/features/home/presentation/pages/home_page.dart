import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../data/repositories/home_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>?> _statsFuture;
  late Future<int> _streakFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = (context.read<AuthBloc>().state as AuthAuthenticated).user.id;
    final homeRepo = HomeRepository();

    _statsFuture = homeRepo.getUserStats(userId);
    _streakFuture = homeRepo.getDailyStreak(userId);

    homeRepo.updateLastLogin(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final userName = state.user.name;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadData();
                });
                await Future.wait([_statsFuture, _streakFuture]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(userName),
                    const SizedBox(height: 32),
                    _buildProgressCard(),
                    const SizedBox(height: 24),
                    _buildStreakCard(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreeting(String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $name 👋',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 8),
        Text(
          'Ready to master traffic rules today?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const _LoadingCard();
        }

        final stats = snapshot.data!;
        final lastScore = stats['last_score'] ?? 0;
        final totalAttempts = stats['total_attempts'] ?? 0;
        final signsLearned = stats['signs_learned'] ?? 0;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Progress',
                        style: AppTextStyles.heading6.copyWith(
                          color: AppColors.textInverse.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Last Score: $lastScore%',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                    ],
                  ),
                  _buildCircleProgress(
                    (lastScore / 100).clamp(0, 1),
                    '$lastScore%',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      'Attempts',
                      totalAttempts.toString(),
                      Icons.assessment,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatBox(
                      'Signs Learned',
                      signsLearned.toString(),
                      Icons.traffic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleProgress(double progress, String label) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: AppColors.textInverse.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.accent,
            ),
          ),
          Center(
            child: Text(
              label,
              style: AppTextStyles.heading5.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textInverse.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.textInverse,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.textInverse,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textInverse.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return FutureBuilder<int>(
      future: _streakFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _LoadingCard();
        }

        final streak = snapshot.data ?? 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🔥', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Streak',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$streak day${streak != 1 ? 's' : ''} in a row',
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.heading5,
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          label: 'Start Mock Test',
          icon: Icons.assignment,
          color: AppColors.primary,
          onPressed: () => context.push('/exam'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: 'Learn Traffic Signs',
          icon: Icons.traffic,
          color: AppColors.accent,
          onPressed: () => context.push('/signs'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: 'Practice Quiz',
          icon: Icons.quiz,
          color: AppColors.success,
          onPressed: () => context.push('/practice'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textInverse),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward, color: color),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
