import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Root widget of the Garblo cross-platform application.
class GarbloApp extends StatelessWidget {
  const GarbloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garblo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
