import 'dart:async';
import 'package:flutter/material.dart';
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
const _kStartedAtMs           = 'flow_started_at_ms';
const _kSelectedProjectId     = 'flow_selected_project_id';
const _kSelectedProjectName   = 'flow_selected_project_name';

// ── Provider exposé ────────────────────────────────────────────
final flowProvider =
    NotifierProvider<FlowNotifier, FlowState>(FlowNotifier.new);

class FlowNotifier extends Notifier<FlowState>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  FlowState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _timer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });
    _loadFromPrefs();
    return const FlowState();
  }

  // ── Détection retour au premier plan ────────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused &&
        this.state.timerState == FlowTimerState.running) {
      // Enregistre l'heure de départ en background
      _saveStartedAt();
    }

    if (state == AppLifecycleState.resumed &&
        this.state.timerState == FlowTimerState.running) {
      _onResumedFromBackground();
    }
  }

  Future<void> _saveStartedAt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kStartedAtMs, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _onResumedFromBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final startedAtMs = prefs.getInt(_kStartedAtMs);
    if (startedAtMs == null) return;

    final elapsed = DateTime.now().millisecondsSinceEpoch - startedAtMs;
    final elapsedSeconds = elapsed ~/ 1000;
    await prefs.remove(_kStartedAtMs);

    if (elapsedSeconds < 3) return; // absence trop courte, on ignore

    final newSecondsLeft = state.secondsLeft - elapsedSeconds;

    if (newSecondsLeft <= 0) {
      // Session terminée pendant le background
      _timer?.cancel();
      _onSessionComplete();
      return;
    }

    if (elapsedSeconds >= 180) {
      // Absence >= 3 min : on met à jour silencieusement (le temps continue)
      state = state.copyWith(secondsLeft: newSecondsLeft);
    } else {
      // Absence < 3 min : on absorbe directement
      state = state.copyWith(secondsLeft: newSecondsLeft);
    }
  }

  // ── Chargement initial depuis SharedPreferences ──────────────
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _resetIfNewDay(prefs);

    final sessionsPerDay  = prefs.getInt(_kSessionsPerDay) ?? 1;
    final completedToday  = prefs.getInt(_kCompletedToday) ?? 0;
    final focusMinutes    = prefs.getInt(_kFocusMinutesToday) ?? 0;
    final projectId       = prefs.getString(_kSelectedProjectId);
    final projectName     = prefs.getString(_kSelectedProjectName);

    state = state.copyWith(
      sessionsPerDay:         sessionsPerDay,
      completedToday:         completedToday,
      totalFocusMinutesToday: focusMinutes,
      selectedProjectId:      projectId,
      selectedProjectName:    projectName,
    );
  }

  void _resetIfNewDay(SharedPreferences prefs) {
    final today     = _todayString();
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

  // ── Sélection du projet avant démarrage ─────────────────────
  Future<void> selectProject({String? id, String? name}) async {
    state = state.copyWith(
      selectedProjectId: id,
      selectedProjectName: name,
    );
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setString(_kSelectedProjectId, id);
      await prefs.setString(_kSelectedProjectName, name ?? '');
    } else {
      await prefs.remove(_kSelectedProjectId);
      await prefs.remove(_kSelectedProjectName);
    }
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
    final newCompleted    = state.completedToday + 1;
    final addedMinutes    = FlowState.sessionDurationSeconds ~/ 60;
    final newFocusMinutes = state.totalFocusMinutesToday + addedMinutes;

    FocusAudioService.instance.stop();

    state = state.copyWith(
      timerState:             FlowTimerState.completed,
      secondsLeft:            0,
      completedToday:         newCompleted,
      totalFocusMinutesToday: newFocusMinutes,
    );

    _persist(completed: newCompleted, focusMinutes: newFocusMinutes);
  }

  Future<void> _persist({
    required int completed,
    required int focusMinutes,
  }) async {
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

    await FlowNotificationService.instance
        .scheduleFlowNotifications(count);
  }
}
