import 'package:flutter/foundation.dart';

/// A simple app-wide notifier for the current bottom navigation index.
/// Widgets can listen to `navIndex` to react to changes, or set its value
/// to request a navigation change.
final ValueNotifier<int> navIndex = ValueNotifier<int>(0);
