import 'package:flutter/material.dart';

import '../features/privacy/presentation/privacy_view.dart';
import 'shell/app_shell.dart';
import 'shell/unknown_route_view.dart';

/// Application routing definitions. The app shell is the main route;
/// pillars switch inside it. Privacy & data opens from the header avatar.
/// The dating routes are retired (CHG-003 W-04).
class AppRouter {
  static const String initialRoute = '/';
  static const String privacyRoute = '/privacy';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: settings,
        );
      case privacyRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const PrivacyView(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => UnknownRouteView(routeName: settings.name),
          settings: settings,
        );
    }
  }
}
