import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/timer_session_repository.dart';

final timerSessionRepositoryProvider = Provider<TimerSessionRepository>(
  (ref) => TimerSessionRepository(Supabase.instance.client),
);
