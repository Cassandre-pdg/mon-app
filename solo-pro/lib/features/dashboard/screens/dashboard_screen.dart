import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';

// Données mock — remplacées par un vrai modèle plus tard
class _DashboardData {
  static const String prenom = 'Alex';
  static const int streak = 3;
  static const double? energyScore = null; // null = check-in pas fait
  static const double sleepHours = 7.5;
  static const bool morningDone = false;
  static const bool eveningDone = false;
  static const String quote =
      '"La productivité, c\'est de choisir ce qui compte vraiment."';
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> _tasks = [
    {'label': 'Finaliser la proposition client', 'done': false},
    {'label': 'Répondre aux emails', 'done': true},
    {'label': 'Préparer la réunion de demain', 'done': false},
  ];

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String get _dateLabel {
    const jours = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    const mois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    final now = DateTime.now();
    return '${jours[now.weekday - 1]} ${now.day} ${mois[now.month - 1]}';
  }

  int get _tasksDone => _tasks.where((t) => t['done'] == true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCheckinBanner(),
              const SizedBox(height: 16),
              _buildEnergyCard(),
              const SizedBox(height: 14),
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildTasksSection(),
              const SizedBox(height: 20),
              _buildQuote(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_greeting ${_DashboardData.prenom} 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(_dateLabel,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.myProfile),
          child: Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                    child: Text('🧑', style: TextStyle(fontSize: 22))),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Bannière check-in ────────────────────────────────────────────────────

  Widget _buildCheckinBanner() {
    final bool isEvening = DateTime.now().hour >= 18;
    final bool isDone =
        isEvening ? _DashboardData.eveningDone : _DashboardData.morningDone;

    if (isDone) return const SizedBox.shrink();

    final String emoji = isEvening ? '🌙' : '☀️';
    final String label =
        isEvening ? 'Check-in du soir disponible' : 'Check-in du matin disponible';
    final String route =
        isEvening ? AppRoutes.eveningCheckin : AppRoutes.morningCheckin;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accentYellow.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.accentYellow.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  )),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // ─── Carte énergie ────────────────────────────────────────────────────────

  Widget _buildEnergyCard() {
    final double? score = _DashboardData.energyScore;
    final bool hasScore = score != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Score énergie',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  hasScore ? '${score.toStringAsFixed(1)} /10' : '— /10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                // Barre de progression
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: hasScore ? score / 10 : 0,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hasScore
                        ? 'Basé sur ton check-in du matin'
                        : 'Fais ton check-in pour le calculer',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _EnergyIcon(score: score),
        ],
      ),
    );
  }

  // ─── Streak + Sommeil ─────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final double sleep = _DashboardData.sleepHours;
    final int streak = _DashboardData.streak;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            emoji: streak > 0 ? '🔥' : '💤',
            value: '$streak jour${streak > 1 ? 's' : ''}',
            label: 'Streak',
            color: AppColors.accentYellow.withValues(alpha: 0.12),
            valueColor: streak > 0
                ? const Color(0xFFFF9F1C)
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            emoji: '😴',
            value: '${sleep}h',
            label: 'Sommeil veille',
            color: AppColors.primary.withValues(alpha: 0.07),
            valueColor: AppColors.primary,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.sleepEntry),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            emoji: '✅',
            value: '$_tasksDone/${_tasks.length}',
            label: 'Tâches',
            color: AppColors.accentGreen.withValues(alpha: 0.1),
            valueColor: AppColors.accentGreen,
          ),
        ),
      ],
    );
  }

  // ─── Tâches ───────────────────────────────────────────────────────────────

  Widget _buildTasksSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mes 3 priorités',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.planner),
              icon: const Icon(Icons.edit_outlined,
                  size: 14, color: AppColors.primary),
              label: const Text('Gérer',
                  style:
                      TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_tasks.isEmpty)
          _buildEmptyTasks()
        else
          ...(_tasks.asMap().entries.map((e) => _buildTaskItem(e.key, e.value))),
      ],
    );
  }

  Widget _buildEmptyTasks() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.planner),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            const Text('✅', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            const Text('Aucune priorité définie',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Ajoute tes 3 tâches clés du jour',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(int index, Map<String, dynamic> task) {
    final bool done = task['done'] as bool;
    return GestureDetector(
      onTap: () => setState(() => _tasks[index]['done'] = !done),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: done
              ? AppColors.accentGreen.withValues(alpha: 0.07)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done
                ? AppColors.accentGreen.withValues(alpha: 0.3)
                : AppColors.textLight.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Checkbox custom
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: done ? AppColors.accentGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: done ? AppColors.accentGreen : AppColors.textLight,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            // Numéro de priorité
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: done
                    ? Colors.transparent
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: done
                        ? AppColors.textLight
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                task['label'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: done
                      ? AppColors.textLight
                      : AppColors.textPrimary,
                  decoration:
                      done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Citation du jour ─────────────────────────────────────────────────────

  Widget _buildQuote() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Citation du jour',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  _DashboardData.quote,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets réutilisables ───────────────────────────────────────────────────

class _EnergyIcon extends StatelessWidget {
  final double? score;

  const _EnergyIcon({this.score});

  @override
  Widget build(BuildContext context) {
    String emoji;
    final s = score;
    if (s == null) {
      emoji = '⚡';
    } else if (s >= 7) {
      emoji = '🚀';
    } else if (s >= 4) {
      emoji = '😊';
    } else {
      emoji = '😔';
    }
    return Text(emoji, style: const TextStyle(fontSize: 52));
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;
  final Color valueColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
    required this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: valueColor)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
