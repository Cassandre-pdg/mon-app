import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/capture_model.dart';
import '../../data/capture_repository.dart';

final captureRepositoryProvider = Provider<CaptureRepository>((ref) {
  return CaptureRepository(Supabase.instance.client);
});

final captureProvider =
    AsyncNotifierProvider<CaptureNotifier, List<CaptureItem>>(
  CaptureNotifier.new,
);

class CaptureNotifier extends AsyncNotifier<List<CaptureItem>> {
  @override
  Future<List<CaptureItem>> build() async {
    return ref.read(captureRepositoryProvider).getAll();
  }

  Future<void> add(String content) async {
    if (content.trim().isEmpty) return;
    final item = await ref.read(captureRepositoryProvider).add(content);
    state = AsyncData([item, ...?state.value]);
  }

  Future<void> markProcessed(String id, {
    String? destination,
    String? destinationId,
  }) async {
    await ref.read(captureRepositoryProvider).markProcessed(
      id,
      destination: destination,
      destinationId: destinationId,
    );
    state = AsyncData(
      state.value!.map((c) {
        if (c.id == id) {
          return c.copyWith(
            isProcessed: true,
            destination: destination,
            destinationId: destinationId,
          );
        }
        return c;
      }).toList(),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(captureRepositoryProvider).delete(id);
    state = AsyncData(state.value!.where((c) => c.id != id).toList());
  }
}

// Nombre de captures en attente (pour badge sur le bouton)
final pendingCapturesCountProvider = Provider<int>((ref) {
  final captures = ref.watch(captureProvider).valueOrNull ?? [];
  return captures.where((c) => !c.isProcessed).length;
});
