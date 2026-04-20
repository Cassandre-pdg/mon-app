import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(Supabase.instance.client);
});

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  return ref.watch(dashboardRepositoryProvider).getDashboardData();
});
