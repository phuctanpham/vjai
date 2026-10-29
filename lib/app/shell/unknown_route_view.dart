import 'package:flutter/material.dart';

/// Explicit destination for routes that do not exist.
class UnknownRouteView extends StatelessWidget {
  final String? routeName;

  const UnknownRouteView({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError('TASK-002-S02');
  }
}
