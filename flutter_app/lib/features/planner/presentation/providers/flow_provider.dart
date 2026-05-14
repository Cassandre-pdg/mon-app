import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/flow_model.dart';
import '../../../../shared/services/flow_notification_service.dart';
import '../../../../shared/services/focus_audio_service.dart';

// ── Clés SharedPreferences ─────────────────────────────────────
const _kSessionsPerDay        = 'flow_sessions_per_day';
const _kCompletedToday        = 'flow_completed_today';
const _kFocusMinutesToday     = 'flow_focus_minutes_today';
const _kLastResetDate         = 'flow_last_reset_date';

// ── Provider exposé ────────────────────────────────────────────
final flowProvider =
    NotifierProvider<FlowNotifier, FlowState>(FlowNotifier.new);

class FlowNotifier extends Notifier<FlowState> {
  Timer? _timer;

  @override
  FlowState build() {
    ref.onDispose(() => _timer?.cancel());
    _loadFromPrefs(); // charge la config + reset quotidien
    return const FlowState();
  }

  // ── Chargement initial depuis SharedPreferences ──────────────
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _resetIfNewDay(prefs);

    final sessionsPerDay = prefs.getInt(_kSessionsPerDay) ?? 1;
    final completedToday = prefs.getInt(_kCompletedToday) ?? 0;
    final focusMinutes   = prefs.getInt(_kFocusMinutesToday) ?? 0;

    state = state.copyWith(
      sessionsPerDay:        sessionsPerDay,
      completedToday:        completedToday,
      totalFocusMinutesToday: focusMinutes,
    );
  }

  /// Remet à zéro les compteurs quotidiens si on est un nouveau jour
  void _resetIfNewDay(SharedPreferences prefs) {
    final today   = _todayString();
    final lastReset = prefs.getString(_kLastResetDate);
    if (lastReset == today) return;

    prefs.setString(_kLastResetDate, today);
    prefs.setInt(_kCompletedToday, 0);
    prefs.setInt(_kFocusMinutesToday, 0);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ── Contrôles du timer ───────────────────────────────────────

  void startPause() {
    if (state.timerState == FlowTimerState.completed) return;

    if (state.timerState == FlowTimerState.running) {
      _timer?.cancel();
      state = state.copyWith(timerState: FlowTimerState.paused);
      FocusAudioService.instance.pause();
    } else {
      final wasPaused = state.timerState == FlowTimerState.paused;
      state = state.copyWith(timerState: FlowTimerState.running);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      if (wasPaused) {
        FocusAudioService.instance.resume();
      } else {
        FocusAudioService.instance.play();
      }
    }
  }

  void reset() {
    _timer?.cancel();
    FocusAudioService.instance.stop();
    state = state.copyWith(
      timerState: FlowTimerState.idle,
      secondsLeft: FlowState.sessionDurationSeconds,
    );
  }

  void dismissCompletion() {
    FocusAudioService.instance.stop();
    state = state.copyWith(
      timerState: FlowTimerState.idle,
      secondsLeft: FlowState.sessionDurationSeconds,
    );
  }

  Future<void> selectAudio(FocusAudio audio) async {
    state = state.copyWith(selectedAudio: audio);
    await FocusAudioService.instance.select(audio);
  }

  void _tick() {
    if (state.secondsLeft <= 1) {
      _timer?.cancel();
      _onSessionComplete();
    } else {
      state = state.copyWith(secondsLeft: state.secondsLeft - 1);
    }
  }

  void _onSessionComplete() {
    final newCompleted     = state.completedToday + 1;
    final addedMinutes     = FlowState.sessionDurationSeconds ~/ 60;
    final newFocusMinutes  = state.totalFocusMinutesToday + addedMinutes;

    FocusAudioService.instance.stop();

    state = state.copyWith(
      timerState:            FlowTimerState.completed,
      secondsLeft:           0,
      completedToday:        newCompleted,
      totalFocusMinutesToday: newFocusMinutes,
    );

    _persist(completed: newCompleted, focusMinutes: newFocusMinutes);
  }

  Future<void> _persist({required int completed, required int focusMinutes}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCompletedToday, completed);
    await prefs.setInt(_kFocusMinutesToday, focusMinutes);
  }

  // ── Configuration sessions par jour ─────────────────────────

  Future<void> setSessionsPerDay(int count) async {
    assert(count == 1 || count == 4, 'sessionsPerDay doit être 1 ou 4');
    state = state.copyWith(sessionsPerDay: count);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSessionsPerDay, count);

    // Re-planifie les notifications avec le nouveau rythme
    await FlowNotificationService.instance.scheduleFlowNotifications(count);
  }
}
