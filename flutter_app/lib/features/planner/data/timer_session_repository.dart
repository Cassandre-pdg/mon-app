import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'session_context_model.dart';

// Migration Supabase à exécuter une fois :
//
// CREATE TABLE timer_sessions (
//   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
//   user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
//   type TEXT NOT NULL CHECK (type IN ('flow', 'pomodoro')),
//   duration_minutes INTEGER NOT NULL,
//   context_type TEXT CHECK (context_type IN ('priority', 'flash', 'other')),
//   context_label TEXT,
//   project_id UUID REFERENCES kanban_projects(id) ON DELETE SET NULL,
//   completed_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
// );
// ALTER TABLE timer_sessions ENABLE ROW LEVEL SECURITY;
// CREATE POLICY "Users own sessions" ON timer_sessions
//   FOR ALL USING (auth.uid() = user_id);

class TimerSessionRepository {
  final SupabaseClient _supabase;
  final _log = Logger();

  TimerSessionRepository(this._supabase);

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<void> save({
    required String type,
    required int durationMinutes,
    SessionContext? context,
  }) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await _supabase.from('timer_sessions').insert({
        'user_id': uid,
        'type': type,
        'duration_minutes': durationMinutes,
        'context_type': context?.type.name,
        'context_label': context?.label,
        'project_id': context?.projectId,
      });
    } catch (e) {
      _log.e('TimerSessionRepository.save', error: e);
    }
  }
}
