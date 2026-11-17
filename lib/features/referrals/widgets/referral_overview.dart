import 'package:flutter/material.dart';

class ReferralOverview extends StatelessWidget {
  final String userId;
  const ReferralOverview({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Referrals: $userId'),
    );
  }

}
