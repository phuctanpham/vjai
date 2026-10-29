import 'package:flutter/material.dart';

import 'shell/app_shell.dart';
import 'shell/unknown_route_view.dart';

/// Application routing definitions. The app shell is the only route; pillars
/// switch inside it. The dating routes are retired (CHG-003 W-04).
class AppRouter {
  static const String initialRoute = '/';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
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
