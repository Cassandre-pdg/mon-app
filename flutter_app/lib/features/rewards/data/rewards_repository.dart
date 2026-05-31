import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

/// Stats d'activité pour le calcul des badges
class RewardsStats {
  final int flashTasksDone;
  final int checkinsCount;
  final int postsCount;
  final int projectsCreated;
  final int projectsCompleted;

  const RewardsStats({
    required this.flashTasksDone,
    required this.checkinsCount,
    required this.postsCount,
    required this.projectsCreated,
    required this.projectsCompleted,
  });

  static const zero = RewardsStats(
    flashTasksDone: 0,
    checkinsCount: 0,
    postsCount: 0,
    projectsCreated: 0,
    projectsCompleted: 0,
  );
}

class RewardsRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger();

  RewardsRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;

  Future<RewardsStats> getStats() async {
    try {
      // Requêtes en parallèle — on récupère les IDs uniquement pour compter
      final results = await Future.wait([
        _supabase
            .from('flash_tasks')
            .select('id')
            .eq('user_id', _userId)
            .eq('is_done', true),
        _supabase
            .from('checkins')
            .select('id')
            .eq('user_id', _userId),
        _supabase
            .from('posts')
            .select('id')
            .eq('user_id', _userId),
        _supabase
            .from('kanban_projects')
            .select('id')
            .eq('user_id', _userId),
        _supabase
            .from('kanban_projects')
            .select('id')
            .eq('user_id', _userId)
            .eq('status', 'done'),
      ]);

      return RewardsStats(
        flashTasksDone:    (results[0] as List).length,
        checkinsCount:     (results[1] as List).length,
        postsCount:        (results[2] as List).length,
        projectsCreated:   (results[3] as List).length,
        projectsCompleted: (results[4] as List).length,
      );
    } catch (e) {
      _logger.e('Erreur chargement stats badges : $e');
      return RewardsStats.zero;
    }
  }
}
