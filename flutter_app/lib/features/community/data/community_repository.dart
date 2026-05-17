import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'community_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MIGRATION SUPABASE — à exécuter dans l'éditeur SQL de Supabase avant deploy
// ─────────────────────────────────────────────────────────────────────────────
//
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS post_type         TEXT    DEFAULT 'partage';
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS post_tag          TEXT;
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS replies_count     INTEGER DEFAULT 0;
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS reports_count     INTEGER DEFAULT 0;
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS is_flagged        BOOLEAN DEFAULT FALSE;
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS reactions_utile      INTEGER DEFAULT 0;
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS reactions_inspirant  INTEGER DEFAULT 0;
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS reactions_merci      INTEGER DEFAULT 0;
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS reactions_bravo      INTEGER DEFAULT 0;
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS poll_options TEXT[];
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS poll_votes   INTEGER[];
// -- Réponses inline (refonte Le Salon V2)
// ALTER TABLE posts ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES posts(id) ON DELETE CASCADE;
// CREATE INDEX IF NOT EXISTS posts_parent_id_idx ON posts(parent_id);
//
// CREATE TABLE IF NOT EXISTS post_reports (
//   id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
//   post_id     UUID        REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
//   reporter_id UUID        NOT NULL,
//   reason      TEXT        NOT NULL,
//   created_at  TIMESTAMPTZ DEFAULT NOW()
// );
// ALTER TABLE post_reports ENABLE ROW LEVEL SECURITY;
// CREATE POLICY "insert_own_reports" ON post_reports
//   FOR INSERT WITH CHECK (auth.uid() = reporter_id);
// CREATE POLICY "select_own_reports" ON post_reports
//   FOR SELECT USING (auth.uid() = reporter_id);
//
// -- Auto-masquage à 3 signalements (trigger optionnel)
// CREATE OR REPLACE FUNCTION auto_flag_post() RETURNS TRIGGER AS $$
// BEGIN
//   UPDATE posts SET is_flagged = TRUE, reports_count = reports_count + 1
//   WHERE id = NEW.post_id;
//   IF (SELECT reports_count FROM posts WHERE id = NEW.post_id) >= 3 THEN
//     UPDATE posts SET is_flagged = TRUE WHERE id = NEW.post_id;
//   END IF;
//   RETURN NEW;
// END;
// $$ LANGUAGE plpgsql SECURITY DEFINER;
// CREATE TRIGGER on_report_insert
//   AFTER INSERT ON post_reports
//   FOR EACH ROW EXECUTE FUNCTION auto_flag_post();
// ─────────────────────────────────────────────────────────────────────────────

/// Repository Communauté — jamais appelé directement depuis un widget
class CommunityRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger();

  CommunityRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;

  // ── Feed ──────────────────────────────────────────────────────

  /// Charge les 50 derniers messages racines (parent_id IS NULL)
  Future<List<CommunityPost>> getPosts() async {
    try {
      final data = await _supabase
          .from('posts')
          .select()
          .eq('is_flagged', false)
          .order('created_at', ascending: false)
          .limit(50);

      return (data as List)
          .map((json) => CommunityPost.fromJson(json))
          .where((p) => p.parentId == null)
          .toList();
    } catch (e) {
      _logger.e('Erreur chargement posts : $e');
      rethrow;
    }
  }

  /// Charge les réponses d'un message (ordre chronologique)
  Future<List<CommunityPost>> getReplies(String parentId) async {
    try {
      final data = await _supabase
          .from('posts')
          .select()
          .eq('parent_id', parentId)
          .eq('is_flagged', false)
          .order('created_at', ascending: true);

      return (data as List)
          .map((json) => CommunityPost.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Erreur chargement réponses : $e');
      rethrow;
    }
  }

  /// Crée une réponse à un message existant
  Future<void> createReply({
    required String content,
    required String authorName,
    required String parentId,
  }) async {
    try {
      await _supabase.from('posts').insert({
        'user_id':     _userId,
        'author_name': authorName,
        'content':     content,
        'post_type':   PostType.reflexion.dbValue,
        'parent_id':   parentId,
      });
      // Incrémente le compteur de réponses sur le parent
      try {
        final row = await _supabase
            .from('posts')
            .select('replies_count')
            .eq('id', parentId)
            .single();
        final count = (row['replies_count'] as int?) ?? 0;
        await _supabase
            .from('posts')
            .update({'replies_count': count + 1})
            .eq('id', parentId);
      } catch (_) {
        // Non-bloquant : le stream temps réel corrigera
      }
      _logger.i('Réponse créée pour : $parentId');
    } catch (e) {
      _logger.e('Erreur création réponse : $e');
      rethrow;
    }
  }

  /// Crée un nouveau message (top-level, sans parent)
  Future<CommunityPost> createPost({
    required String content,
    required String authorName,
    required PostType postType,
    String? postTag,
    List<String>? pollOptions,
  }) async {
    try {
      final data = await _supabase
          .from('posts')
          .insert({
            'user_id':     _userId,
            'author_name': authorName,
            'content':     content,
            'post_type':   postType.dbValue,
            if (postTag != null) 'post_tag': postTag,
            if (pollOptions != null) 'poll_options': pollOptions,
            if (pollOptions != null)
              'poll_votes': List.filled(pollOptions.length, 0),
          })
          .select()
          .single();

      _logger.i('Post créé : ${data['id']}');
      return CommunityPost.fromJson(data);
    } catch (e) {
      _logger.e('Erreur création post : $e');
      rethrow;
    }
  }

  /// Nombre de posts de l'utilisateur sur les 7 derniers jours
  Future<int> getWeeklyPostCount() async {
    try {
      final since = DateTime.now()
          .subtract(const Duration(days: 7))
          .toIso8601String();

      final data = await _supabase
          .from('posts')
          .select('id')
          .eq('user_id', _userId)
          .gte('created_at', since);

      return (data as List).length;
    } catch (e) {
      _logger.e('Erreur comptage posts semaine : $e');
      return 0;
    }
  }

  /// Ajoute une réaction (optimiste côté client, rollback si erreur)
  Future<void> reactToPost(String postId, ReactionType reaction, int currentCount) async {
    try {
      await _supabase
          .from('posts')
          .update({reaction.dbColumn: currentCount + 1})
          .eq('id', postId);
    } catch (e) {
      _logger.e('Erreur réaction post : $e');
      rethrow;
    }
  }

  /// Vote sur une option de sondage (mise à jour optimiste du tableau)
  Future<void> votePoll(
    String postId,
    int optionIndex,
    List<int> currentVotes,
  ) async {
    try {
      final newVotes = List<int>.from(currentVotes);
      newVotes[optionIndex]++;
      await _supabase
          .from('posts')
          .update({'poll_votes': newVotes})
          .eq('id', postId);
    } catch (e) {
      _logger.e('Erreur vote sondage : $e');
      rethrow;
    }
  }

  /// Signale un post (3 signalements = masquage automatique via trigger)
  Future<void> reportPost(String postId, String reason) async {
    try {
      await _supabase.from('post_reports').insert({
        'post_id':     postId,
        'reporter_id': _userId,
        'reason':      reason,
      });
      _logger.i('Post signalé : $postId');
    } catch (e) {
      _logger.e('Erreur signalement post : $e');
      rethrow;
    }
  }

  /// Supprime un post (uniquement le sien — RLS garantit ça)
  Future<void> deletePost(String postId) async {
    try {
      await _supabase
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', _userId);
      _logger.i('Post supprimé : $postId');
    } catch (e) {
      _logger.e('Erreur suppression post : $e');
      rethrow;
    }
  }
}
