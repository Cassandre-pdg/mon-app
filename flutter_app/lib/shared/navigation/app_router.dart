import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/planner/presentation/screens/planner_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/sleep/presentation/screens/sleep_screen.dart';
import '../../features/checkin/presentation/screens/checkin_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/rewards/presentation/screens/rewards_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../constants/app_strings.dart';

class AppRoutes {
  static const String auth       = '/auth';
  static const String onboarding = '/onboarding';
  static const String home       = '/home';
  static const String planner    = '/planner';
  static const String community  = '/community';
  static const String sleep      = '/sleep';
  static const String profile    = '/profile';
  static const String checkinMorning = '/checkin/morning';
  static const String checkinEvening = '/checkin/evening';
  static const String settings              = '/settings';
  static const String notificationSettings  = '/settings/notifications';
  static const String rewards               = '/rewards';
  static const String paywall               = '/paywall';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Écoute les changements d'état Auth pour rediriger
  final authNotifier = ValueNotifier<bool>(
    Supabase.instance.client.auth.currentUser != null,
  );

  // Met à jour quand l'état change
  ref.listen(authStateProvider, (_, next) {
    next.whenData((state) {
      authNotifier.value = state.session != null;
    });
  });

  return GoRouter(
    initialLocation: Supabase.instance.client.auth.currentUser != null
        ? AppRoutes.home
        : AppRoutes.auth,
    refreshListenable: authNotifier,

    // Redirection automatique selon l'état Auth
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      final isOnAuth = state.matchedLocation == AppRoutes.auth;

      // Pas connecté → page Auth
      if (!isLoggedIn && !isOnAuth) return AppRoutes.auth;
      // Connecté sur Auth → Home
      if (isLoggedIn && isOnAuth) return AppRoutes.home;

      return null; // pas de redirection
    },

    routes: [
      // Auth
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Badges (sans barre de navigation)
      GoRoute(
        path: AppRoutes.rewards,
        builder: (context, state) => const RewardsScreen(),
      ),

      // Paramètres notifications (sans barre de navigation)
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      // Paywall Pro (sans barre de navigation)
      // Paramètre optionnel : ?dismissible=false pour bloquer la fermeture
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) {
          final dismissible =
              state.uri.queryParameters['dismissible'] != 'false';
          return PaywallScreen(isDismissible: dismissible);
        },
      ),

      // Check-ins (sans barre de navigation)
      GoRoute(
        path: AppRoutes.checkinMorning,
        builder: (context, state) => const CheckinScreen(type: 'morning'),
      ),
      GoRoute(
        path: AppRoutes.checkinEvening,
        builder: (context, state) => const CheckinScreen(type: 'evening'),
      ),

      // App principale avec barre de navigation
      ShellRoute(
        builder: (context, state, child) => _ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.planner,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PlannerScreen()),
          ),
          GoRoute(
            path: AppRoutes.community,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CommunityScreen()),
          ),
          GoRoute(
            path: AppRoutes.sleep,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SleepScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});

// ── Scaffold avec barre de navigation 5 onglets ──────────────
class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.child});
  final Widget child;

  static const _routes = [
    AppRoutes.home,
    AppRoutes.planner,
    AppRoutes.community,
    AppRoutes.sleep,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex =
        _routes.indexWhere((r) => location.startsWith(r)).clamp(0, 4);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => context.go(_routes[index]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_rounded),
            label: AppStrings.navPlanner,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: AppStrings.navCommunity,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bedtime_rounded),
            label: AppStrings.navSleep,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}
