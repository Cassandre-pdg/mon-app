import 'package:supabase_flutter/supabase_flutter.dart';
import 'capture_model.dart';

class CaptureRepository {
  final SupabaseClient _supabase;

  CaptureRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;

  Future<CaptureItem> add(String content) async {
    final data = await _supabase
        .from('captures')
        .insert({'user_id': _userId, 'content': content.trim()})
        .select()
        .single();
    return CaptureItem.fromJson(data);
  }

  // Récupère les captures non traitées (pour la revue de semaine)
  Future<List<CaptureItem>> getPending() async {
    final data = await _supabase
        .from('captures')
        .select()
        .eq('user_id', _userId)
        .eq('is_processed', false)
        .order('created_at', ascending: false);
    return (data as List).map((e) => CaptureItem.fromJson(e)).toList();
  }

  Future<List<CaptureItem>> getAll({int limit = 50}) async {
    final data = await _supabase
        .from('captures')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => CaptureItem.fromJson(e)).toList();
  }

  Future<void> markProcessed(String id, {
    String? destination,
    String? destinationId,
  }) async {
    await _supabase
        .from('captures')
        .update({
          'is_processed':   true,
          'destination':    destination,
          'destination_id': destinationId,
        })
        .eq('id', id)
        .eq('user_id', _userId);
  }

  Future<void> delete(String id) async {
    await _supabase
        .from('captures')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
