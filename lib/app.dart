import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'domain/providers/theme_provider.dart';

class GoodLoopApp extends ConsumerWidget {
  const GoodLoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final routerConfig = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'GoodLoop',
      debugShowCheckedModeBanner: false,
      routerConfig: routerConfig,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
    );
  }
}
