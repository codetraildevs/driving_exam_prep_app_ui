import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/theme/app_theme.dart';
import 'config/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mjxsrxnyfcjuhsudiyku.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1qeHNyeG55ZmNqdWhzdWRpeWt1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1Mjg5MTIsImV4cCI6MjA4ODEwNDkxMn0.SHvvA86dswxWLDPHxLkhsvTq-aIiMAGnXH5D2TB1cn0',
  );

  runApp(const TrafficRulesApp());
}

class TrafficRulesApp extends StatelessWidget {
  const TrafficRulesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(CheckAuthStatusEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Traffic Rules Learning App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
