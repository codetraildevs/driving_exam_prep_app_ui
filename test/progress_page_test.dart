import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/progress/presentation/pages/progress_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/network/api_helper.dart';

void main() {
  testWidgets('offline progress retains pending attempts and their pass status', (tester) async {
    SharedPreferences.setMockInitialValues({
      'offline_cache_pending_results': jsonEncode([
        {'userId':'u1','clientResultId':'local1','score':90,'totalQuestions':20,'correctAnswers':18,'createdAt':'2026-10-01'},
        {'userId':'other','clientResultId':'local2','score':100},
      ]),
    });
    final bloc = AuthBloc()..emit(AuthAuthenticated(UserModel(id:'u1',name:'Driver',phoneNumber:'0788123456',createdAt:DateTime(2026),updatedAt:DateTime(2026))));
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider.value(value:bloc, child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProgressPage(loadResults: (_) async => const ApiResponse(statusCode:0,data:null,isSuccess:false,debugInfo:'offline')),
    )));
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(tester.element(find.byType(ProgressPage)));
    expect(find.text('1 / 1 ${l.progressPassedCount}'), findsOneWidget);
    expect(find.text(l.progressSaved), findsOneWidget);
    expect(find.text(l.progressPassed), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
