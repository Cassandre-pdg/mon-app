import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Signal de rafraîchissement du dashboard.
/// Incrémenter ce provider force le dashboardProvider à se re-fetcher.
/// Utilisé par checkinNotifierProvider après soumission d'un check-in.
final dashboardRefreshSignal = StateProvider<int>((ref) => 0);

/// Signal de rafraîchissement du profil (streaks, niveau, points).
/// Incrémenter ce provider force le profileStatsProvider à se re-fetcher.
final profileRefreshSignal = StateProvider<int>((ref) => 0);
