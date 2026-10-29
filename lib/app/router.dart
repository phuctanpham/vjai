import 'package:flutter/material.dart';
import '../features/discovery/presentation/discovery_view.dart';

/// Application routing definitions.
class AppRouter {
  static const String initialRoute = '/';
  static const String discoveryRoute = '/discovery';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
      case discoveryRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const DiscoveryView(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
