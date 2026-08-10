// ============================================================================
// Test Logging Wrapper Widget
// ============================================================================
// Wraps any screen to automatically log user interactions.
// Place at the top of any screen's build method.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/test_logging_service.dart';

/// Wrapper widget that logs all user interactions on the wrapped child
class TestLoggingWrapper extends StatelessWidget {
  final String screenName;
  final Widget child;
  final bool enableTapLogging;
  final bool enableScrollLogging;

  const TestLoggingWrapper({
    super.key,
    required this.screenName,
    required this.child,
    this.enableTapLogging = true,
    this.enableScrollLogging = true,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: enableScrollLogging
          ? (notification) {
              if (notification is ScrollUpdateNotification) {
                testLogger.logScroll(
                  screenName,
                  notification.metrics.pixels,
                  direction: notification.metrics.pixels > 0 ? 'down' : 'up',
                );
              }
              return false;
            }
          : null,
      child: enableTapLogging
          ? _TapLoggingBuilder(screenName: screenName, child: child)
          : child,
    );
  }
}

/// Helper widget to log taps on interactive elements
class _TapLoggingBuilder extends StatelessWidget {
  final String screenName;
  final Widget child;

  const _TapLoggingBuilder({required this.screenName, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final widget = _findWidgetAtPosition(context, box.globalToLocal(event.position));
          if (widget != null) {
            final widgetName = _getWidgetName(widget);
            if (widgetName.isNotEmpty) {
              testLogger.logTap(screenName, widgetName);
            }
          }
        }
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }

  Widget? _findWidgetAtPosition(BuildContext context, Offset position) {
    return context.widget;
  }

  String _getWidgetName(Widget widget) {
    final type = widget.runtimeType.toString();
    if (type.startsWith('_')) return '';
    return type;
  }
}

/// Extension to easily wrap any screen for logging
extension TestLoggingExtension on BuildContext {
  void logTap(String widgetName) {
    final screen = _getScreenNameFromContext(this);
    testLogger.logTap(screen, widgetName);
  }

  void logNavigation(String toScreen) {
    final screen = _getScreenNameFromContext(this);
    testLogger.logNavigation(screen, toScreen);
  }
}

String _getScreenNameFromContext(BuildContext context) {
  final router = GoRouter.of(context);
  final location = router.routeInformationProvider.value.uri.path;
  return _pathToScreenName(location);
}

String _pathToScreenName(String path) {
  final parts = path.split('/').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return 'Unknown';

  final screenName = parts.map((p) {
    if (p.isEmpty) return p;
    return p[0].toUpperCase() + p.substring(1);
  }).join();

  return screenName;
}
