import 'package:flutter/material.dart';

import 'app/bootstrap.dart';

/// Opens the local store first, then runs the app on it (TASK-005).
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GarbloBootstrap());
}
