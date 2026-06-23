import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/dashboard_repository.dart';
import '../../../../shared/providers/refresh_signals.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(Supabase.instance.client);
});

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  // Se re-fetche automatiquement quand un check-in est soumis
  ref.watch(dashboardRefreshSignal);
  return ref.watch(dashboardRepositoryProvider).getDashboardData();
});
