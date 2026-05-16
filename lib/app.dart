import 'package:flutter/material.dart';

import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'core/registry/tool_registry.dart';
import 'core/routing/app_router.dart';

class DevToolsHubApp extends StatelessWidget {
  const DevToolsHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'DevTools Hub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(
            seedColor: AppSettings.instance.accentColor,
            compactMode: AppSettings.instance.compactMode,
          ),
          darkTheme: AppTheme.dark(
            seedColor: AppSettings.instance.accentColor,
            compactMode: AppSettings.instance.compactMode,
          ),
          themeMode: AppSettings.instance.themeMode,
          initialRoute: ToolRegistry.homeRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(AppSettings.instance.fontScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}

