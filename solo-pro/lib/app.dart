import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'features/onboarding/screens/auth_screen.dart';
import 'features/onboarding/screens/quick_profile_screen.dart';
import 'features/onboarding/screens/first_checkin_screen.dart';
import 'features/checkin/screens/morning_checkin_screen.dart';
import 'features/checkin/screens/evening_checkin_screen.dart';
import 'features/checkin/screens/checkin_history_screen.dart';
import 'features/journee/screens/focus_tool_screen.dart';
import 'features/journee/screens/week_review_screen.dart';
import 'features/sommeil/screens/sleep_entry_screen.dart';
import 'features/sommeil/screens/sleep_graphs_screen.dart';
import 'features/profil/screens/settings_screen.dart';
import 'features/tribu/screens/groups_screen.dart';
import 'features/tribu/screens/member_profile_screen.dart';
import 'shared/navigation/main_navigation.dart';

class SoloProApp extends StatelessWidget {
  const SoloProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoloPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.auth: (_) => const AuthScreen(),
        AppRoutes.quickProfile: (_) => const QuickProfileScreen(),
        AppRoutes.firstCheckin: (_) => const FirstCheckinScreen(),
        AppRoutes.home: (_) => const MainNavigation(),
        AppRoutes.morningCheckin: (_) => const MorningCheckinScreen(),
        AppRoutes.eveningCheckin: (_) => const EveningCheckinScreen(),
        AppRoutes.checkinHistory: (_) => const CheckinHistoryScreen(),
        AppRoutes.focusTool: (_) => const FocusToolScreen(),
        AppRoutes.weekReview: (_) => const WeekReviewScreen(),
        AppRoutes.sleepEntry: (_) => const SleepEntryScreen(),
        AppRoutes.sleepGraphs: (_) => const SleepGraphsScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.tribuGroups: (_) => const GroupsScreen(),
        AppRoutes.memberProfile: (_) => const MemberProfileScreen(),
      },
    );
  }
}
