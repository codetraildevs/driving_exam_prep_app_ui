import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/referral_overview.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.referralTitle),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, auth) {
          if (auth is! AuthAuthenticated) {
            return const Center(child: Text('Not authenticated'));
          }
          return const ReferralOverview(userId: 'pending');
        },
      ),
    );
  }
}
