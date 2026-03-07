import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxContentWidth = screenWidth > 600 ? 500.0 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;
          final l10n = AppLocalizations.of(context);

          return SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // ================= HEADER =================
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          bottom:
                              BorderSide(color: AppColors.primary.withOpacity(0.1)),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => context.go('/home'),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                l10n.profileTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          // IconButton(
                          //   icon: const Icon(Icons.more_vert),
                          //   onPressed: () {},
                          // ),
                        ],
                      ),
                    ),

                    // ================= CONTENT =================
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Center(
                          child: Container(
                            constraints:
                                BoxConstraints(maxWidth: maxContentWidth),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ================= PROFILE HEADER =================
                                Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient:
                                                AppColors.primaryGradient,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withOpacity(0.3),
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              user.name[0].toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      user.name,
                                      style: AppTextStyles.heading3,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 16,
                                            color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.profileLocation,
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),

                                // ================= PROGRESS CARD =================
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: AppColors.primary
                                            .withOpacity(0.05)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              l10n.profileOverallProgress,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            "75%",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        child: LinearProgressIndicator(
                                          value: 0.75,
                                          minHeight: 10,
                                          backgroundColor:
                                              AppColors.primary.withOpacity(0.1),
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.profileModulesCompleted(15, 20),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color:
                                                AppColors.textSecondary),
                                      )
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // ================= MENU SECTION =================
                                // const Text(
                                //   "Activities & Progress",
                                //   style: TextStyle(
                                //       fontSize: 12,
                                //       fontWeight: FontWeight.bold,
                                //       color: AppColors.textSecondary),
                                // ),
                                // const SizedBox(height: 12),

//                               _menuTile(
//   icon: Icons.card_membership,
//   title: "My Certificates",
//   subtitle: "3 earned, 1 pending",
//   onTap: () => context.push('/certificates'),
// ),

                                const SizedBox(height: 24),
                                Text(
                                  l10n.profileAccount,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 12),

                                _menuTile(
                                  icon: Icons.settings,
                                  title: l10n.profileSettings,
                                  subtitle:
                                      l10n.profileSettingsSubtitle,
                                  onTap: () => context.push('/settings'),
                                ),

                                const SizedBox(height: 20),
                                // ================= DELETE ACCOUNT =================
ListTile(
  onTap: () => _showDeleteDialog(context),
  leading: const Icon(Icons.delete_forever, color: Colors.red),
  title: Text(
    l10n.profileDeleteAccount,
    style: const TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.w600,
    ),
  ),
),

                                // ================= LOGOUT =================
                                ListTile(
                                  onTap: () {
                                    context
                                        .read<AuthBloc>()
                                        .add(const SignOutEvent());
                                    context.go('/landing');
                                  },
                                  leading: const Icon(Icons.logout,
                                      color: Colors.red),
                                  title: Text(
                                    l10n.profileSignOut,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              
              ],
            ),
          );
        },
      ),
    );
  }
void _showDeleteDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(l10n.profileDeleteConfirmTitle),
      content: Text(
        l10n.profileDeleteConfirmMessage,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () {
            // TODO: Dispatch delete event
            context.read<AuthBloc>().add(const SignOutEvent());
            context.go('/landing');
          },
          child: Text(
            l10n.profileDelete,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
  static Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

