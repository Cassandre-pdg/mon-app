import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/objectives/presentation/screens/objectives_screen.dart';
import '../../features/planner/presentation/screens/planner_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/checkin/presentation/screens/checkin_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/rewards/presentation/screens/rewards_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../../features/capture/presentation/providers/capture_provider.dart';
import '../../features/capture/presentation/widgets/capture_bottom_sheet.dart';

class AppRoutes {
  static const String auth       = '/auth';
  static const String onboarding = '/onboarding';
  static const String home       = '/home';
  static const String objectives = '/objectives';
  static const String planner    = '/planner';
  static const String community  = '/community';
  static const String profile    = '/profile';
  static const String checkinMorning        = '/checkin/morning';
  static const String checkinEvening        = '/checkin/evening';
  static const String settings              = '/settings';
  static const String notificationSettings  = '/settings/notifications';
  static const String rewards               = '/rewards';
  static const String paywall               = '/paywall';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(
    Supabase.instance.client.auth.currentUser != null,
  );

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

    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      final isOnAuth = state.matchedLocation == AppRoutes.auth;
      if (!isLoggedIn && !isOnAuth) return AppRoutes.auth;
      if (isLoggedIn && isOnAuth) return AppRoutes.home;
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.rewards,
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) {
          final dismissible =
              state.uri.queryParameters['dismissible'] != 'false';
          return PaywallScreen(isDismissible: dismissible);
        },
      ),
      GoRoute(
        path: AppRoutes.checkinMorning,
        builder: (context, state) => const CheckinScreen(type: 'morning'),
      ),
      GoRoute(
        path: AppRoutes.checkinEvening,
        builder: (context, state) => const CheckinScreen(type: 'evening'),
      ),

      // ── App principale : 5 onglets ───────────────────────
      // [ Mon Espace ] [ Objectifs ] [ Ma Journée ] [ Le Salon ] [ Mon Profil ]
      ShellRoute(
        builder: (context, state, child) => _ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.objectives,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ObjectivesScreen()),
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
class _ScaffoldWithNav extends ConsumerWidget {
  const _ScaffoldWithNav({required this.child});
  final Widget child;

  static const _routes = [
    AppRoutes.home,
    AppRoutes.objectives,
    AppRoutes.planner,
    AppRoutes.community,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex =
        _routes.indexWhere((r) => location.startsWith(r)).clamp(0, 4);
    final pendingCount = ref.watch(pendingCapturesCountProvider);

    return Scaffold(
      body: Stack(
        children: [
          child,
          // ── Bouton capture brain dump (haut droite) ──────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: GestureDetector(
                  onTap: () => showCaptureSheet(context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      // Badge rouge si notes en attente
                      if (pendingCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                pendingCount > 9 ? '9+' : '$pendingCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _KolybNavBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_routes[i]),
      ),
    );
  }
}

// ── Tab bar flottante glass ────────────────────────────────────
class _KolybNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _KolybNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.home_rounded,          AppStrings.navHome),
    (Icons.flag_rounded,          AppStrings.navObjectives),
    (Icons.check_circle_rounded,  AppStrings.navPlanner),
    (Icons.people_rounded,        AppStrings.navCommunity),
    (Icons.person_rounded,        AppStrings.navProfile),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bottomPad  = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16, 6, 16, bottomPad + 10),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xF20A0B1A)
              : const Color(0xF5FFFFFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? const Color(0x18FFFFFF)
                : const Color(0x14000000),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D28D9).withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_items.length, (i) {
            final (icon, label) = _items[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: _NavItem(
                  icon: icon,
                  label: label,
                  isActive: i == currentIndex,
                  isDark: isDark,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Item de la tab bar ────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor   = const Color(0xFF6D28D9);
    final inactiveColor = isDark
        ? const Color(0xFFEDEDFF).withValues(alpha: 0.35)
        : const Color(0xFF12122A).withValues(alpha: 0.35);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 14 : 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? Colors.white : inactiveColor,
          ),
        ),
        const SizedBox(height: 2),
        AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 180),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? const Color(0xFFEDEDFF)
                  : const Color(0xFF12122A),
            ),
          ),
        ),
      ],
    );
  }
}
