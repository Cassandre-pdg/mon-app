import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_provider.dart';
import 'shared/navigation/app_router.dart';
import 'shared/constants/app_constants.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/flow_notification_service.dart';
import 'features/subscription/data/subscription_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation locale française (pour DateFormat)
  await initializeDateFormatting('fr_FR', null);

  // Firebase + notifications : non supportés sur web (FCM = mobile uniquement)
  if (!kIsWeb) {
    await Firebase.initializeApp();
    await NotificationService.instance.init();
    await FlowNotificationService.instance.init();
  }

  // Initialisation Supabase (EU Frankfurt — RGPD)
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialisation RevenueCat (mobile uniquement)
  // L'userId Supabase est associé après login via SubscriptionRepository.identifyUser()
  if (!kIsWeb) {
    final supabaseUserId =
        Supabase.instance.client.auth.currentUser?.id;
    await SubscriptionRepository.instance.init(userId: supabaseUserId);
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
