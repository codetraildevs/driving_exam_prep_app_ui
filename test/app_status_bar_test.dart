import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/config/theme/app_colors.dart';
import 'package:traffic_rule_in_rwanda/shared/widgets/app_status_bar.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('status bar stays white on purple in $brightness', (tester) async {
      tester.view.viewPadding = const FakeViewPadding(top: 24);
      tester.view.padding = const FakeViewPadding(top: 24);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: brightness),
        builder: (_, child) => AppStatusBar(child: child!),
        home: Scaffold(appBar: AppBar(title: const Text('Page'))),
      ));
      await tester.pumpAndSettle();
      expect(SystemChrome.latestStyle?.statusBarIconBrightness, Brightness.light);
      final background = find.byWidgetPredicate(
        (widget) => widget is ColoredBox && widget.color == AppColors.primary,
      );
      expect(tester.getSize(background).height, 24);
      expect(tester.getTopLeft(background).dy, 0);
      expect(MediaQuery.paddingOf(tester.element(find.byType(Scaffold))).top, 24);
    });
  }

  testWidgets('side insets keep content clear of the navigation bar', (
    tester,
  ) async {
    tester.view.viewPadding = const FakeViewPadding(right: 72);
    tester.view.padding = const FakeViewPadding(right: 72);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => SystemBarInsets(child: child!),
        home: const Scaffold(body: SizedBox.expand(key: Key('content'))),
      ),
    );
    await tester.pumpAndSettle();

    // The page stops short of the 72px landscape navigation bar...
    expect(tester.getRect(find.byType(Scaffold)).right, 1024 - 72);
    expect(tester.getRect(find.byKey(const Key('content'))).right, 1024 - 72);
    // ...and the inset is consumed, so a SafeArea inside the page adds nothing.
    final pageContext = tester.element(find.byType(Scaffold));
    expect(MediaQuery.paddingOf(pageContext).right, 0);
  });
}
