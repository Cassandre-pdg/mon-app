import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/sleep_repository.dart';
import '../../data/sleep_model.dart';

final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  return SleepRepository(Supabase.instance.client);
});

final sleepLogsProvider =
    AsyncNotifierProvider<SleepNotifier, List<SleepLog>>(SleepNotifier.new);

class SleepNotifier extends AsyncNotifier<List<SleepLog>> {
  @override
  Future<List<SleepLog>> build() async {
    return ref.watch(sleepRepositoryProvider).getRecentLogs();
  }

  Future<void> addLog({
    required String sleepDate,
    required String bedtime,
    required String wakeTime,
    int? qualityScore,
    String? notes,
  }) async {
    final log = await ref.read(sleepRepositoryProvider).createLog(
          sleepDate: sleepDate,
          bedtime: bedtime,
          wakeTime: wakeTime,
          qualityScore: qualityScore,
          notes: notes,
        );
    state = AsyncData([log, ...?state.value]);
  }
}
