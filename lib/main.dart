import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goodloop/firebase_options.dart';
import 'app.dart';
import 'domain/providers/notification_service.dart';
import 'logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final notificationService = NotificationService();
    await notificationService.configureLocalTimeZone();
    await notificationService.initialize();
  } catch (e, stack) {
    logger.e("Błąd podczas inicjalizacji aplikacji",
        error: e, stackTrace: stack);
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: GoodLoopApp()));
}
