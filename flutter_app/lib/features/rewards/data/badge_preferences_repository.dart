import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BadgePreferencesRepository {
  static const _keyDates  = 'badge_unlock_dates_v1';
  static const _keyPinned = 'badge_pinned_ids_v1';
  static const maxPinned  = 3;

  // ── Dates d'obtention ─────────────────────────────────────
  Future<Map<String, DateTime>> getUnlockDates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyDates);
    if (raw == null) return {};
    final map = Map<String, String>.from(jsonDecode(raw));
    return map.map((k, v) => MapEntry(k, DateTime.parse(v)));
  }

  /// Enregistre la date du jour pour le badge, uniquement si pas encore fait.
  Future<void> markUnlockedIfNew(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyDates) ?? '{}';
    final map = Map<String, String>.from(jsonDecode(raw));
    if (!map.containsKey(badgeId)) {
      map[badgeId] = DateTime.now().toIso8601String();
      await prefs.setString(_keyDates, jsonEncode(map));
    }
  }

  /// Formate une date de déverrouillage pour l'affichage.
  static String formatDate(DateTime date) {
    return DateFormat("d MMMM yyyy", 'fr_FR').format(date);
  }

  // ── Badges épinglés ───────────────────────────────────────
  Future<List<String>> getPinnedBadgeIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPinned) ?? [];
  }

  /// Épingle ou désépingle un badge. Limite : 3 épinglés max.
  /// Retourne true si le badge est maintenant épinglé, false sinon.
  Future<bool> togglePin(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final pinned = List<String>.from(
      prefs.getStringList(_keyPinned) ?? [],
    );
    if (pinned.contains(badgeId)) {
      pinned.remove(badgeId);
      await prefs.setStringList(_keyPinned, pinned);
      return false;
    } else if (pinned.length < maxPinned) {
      pinned.add(badgeId);
      await prefs.setStringList(_keyPinned, pinned);
      return true;
    }
    return false; // limite atteinte
  }
}
