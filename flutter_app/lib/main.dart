import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';

import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_provider.dart';
import 'shared/navigation/app_router.dart';
import 'shared/constants/app_constants.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/flow_notification_service.dart';
import 'shared/services/monthly_reminders_service.dart';
import 'features/subscription/data/subscription_repository.dart';

final _log = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation locale française (pour DateFormat)
  await initializeDateFormatting('fr_FR', null);

  // Firebase + notifications : non supportés sur web (FCM = mobile uniquement)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      _log.e('[main] Firebase init error: $e');
    }

    try {
      await NotificationService.instance.init();
      await FlowNotificationService.instance.init();
      await MonthlyRemindersService.instance.init();
      // scheduleAll peut lancer une PlatformException si SCHEDULE_EXACT_ALARM
      // n'est pas accordée (Android 12+) — on laisse l'app démarrer quand même.
      await MonthlyRemindersService.instance.scheduleAll();
    } catch (e) {
      _log.w('[main] Notifications init error (non bloquant): $e');
    }
  }

  // Initialisation Supabase (EU Frankfurt — RGPD)
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  } catch (e) {
    _log.e('[main] Supabase init error: $e');
  }

  // Initialisation RevenueCat (mobile uniquement)
  if (!kIsWeb) {
    try {
      final supabaseUserId =
          Supabase.instance.client.auth.currentUser?.id;
      await SubscriptionRepository.instance.init(userId: supabaseUserId);
    } catch (e) {
      _log.w('[main] RevenueCat init error (non bloquant): $e');
    }
  }

  runApp(
    const ProviderScope(
      child: KolybApp(),
    ),
  );
}

/// Raccourci global vers le client Supabase
final supabase = Supabase.instance.client;

class KolybApp extends ConsumerWidget {
  const KolybApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
