import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'community_model.dart';

/// Repository Communauté — jamais appelé directement depuis un widget
class CommunityRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger();

  CommunityRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;

  // ── Feed ──────────────────────────────────────────────────────

  /// Charge les 50 derniers posts du feed global
  Future<List<CommunityPost>> getPosts() async {
    try {
      final data = await _supabase
          .from('posts')
          .select('id, user_id, author_name, content, likes_count, created_at')
          .order('created_at', ascending: false)
          .limit(50);

      return (data as List)
          .map((json) => CommunityPost.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Erreur chargement posts : $e');
      rethrow;
    }
  }

  /// Crée un nouveau post
  Future<CommunityPost> createPost({
    required String content,
    required String authorName,
  }) async {
    try {
      final data = await _supabase
          .from('posts')
          .insert({
            'user_id': _userId,
            'author_name': authorName,
            'content': content,
            'likes_count': 0,
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

  /// Incrémente le like d'un post (optimiste côté client)
  Future<void> likePost(String postId, int currentLikes) async {
    try {
      await _supabase
          .from('posts')
          .update({'likes_count': currentLikes + 1})
          .eq('id', postId);
    } catch (e) {
      _logger.e('Erreur like post : $e');
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
