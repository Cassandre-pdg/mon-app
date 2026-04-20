import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/pomodoro_timer.dart';
import '../widgets/eisenhower_matrix.dart';
import '../widgets/deep_work_session.dart';

class FocusToolScreen extends StatefulWidget {
  const FocusToolScreen({super.key});

  @override
  State<FocusToolScreen> createState() => _FocusToolScreenState();
}

class _FocusToolScreenState extends State<FocusToolScreen> {
  int? _selected; // 0=Pomodoro 1=Eisenhower 2=DeepWork

  final List<_ToolCard> _tools = const [
    _ToolCard(
      emoji: '🍅',
      title: 'Pomodoro',
      subtitle: '25 min de focus\n5 min de pause',
      description: 'Travaille en sprints courts. Idéal pour les tâches répétitives ou quand tu as du mal à démarrer.',
      color: Color(0xFFFF6B6B),
    ),
    _ToolCard(
      emoji: '⚡',
      title: 'Eisenhower',
      subtitle: 'Urgent vs Important\nOrganise tes priorités',
      description: 'Classe tes tâches dans 4 quadrants pour décider quoi faire, planifier, déléguer ou supprimer.',
      color: Color(0xFF6C63FF),
    ),
    _ToolCard(
      emoji: '🧠',
      title: 'Deep Work',
      subtitle: 'Session longue\nZéro distraction',
      description: 'Bloc de 90 min de travail profond. Pour les tâches complexes qui demandent toute ta concentration.',
      color: Color(0xFF4CAF50),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Outil Focus 🎯'),
        leading: _selected != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => setState(() => _selected = null),
              )
            : null,
      ),
      body: _selected == null
          ? _buildSelection()
          : _buildTool(_selected!),
    );
  }

  // ─── Sélection ────────────────────────────────────────────────────────────

  Widget _buildSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Quel mode de travail pour aujourd\'hui ?',
            style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4),
          ),
          const SizedBox(height: 24),
          ...List.generate(_tools.length, (i) {
            final t = _tools[i];
            return GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: t.color.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: t.color.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: t.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                            child: Text(t.emoji,
                                style: const TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 3),
                            Text(t.subtitle,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.4)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 14, color: t.color),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          // Conseil Solo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                      child: Text('🤖',
                          style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Conseil de Solo : commence par le Pomodoro si tu as du mal à te lancer. 25 min, c\'est toujours faisable !',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Outil actif ──────────────────────────────────────────────────────────

  Widget _buildTool(int index) {
    switch (index) {
      case 0:
        return const PomodoroTimer();
      case 1:
        return const EisenhowerMatrix();
      case 2:
        return const DeepWorkSession();
      default:
        return const SizedBox();
    }
  }
}

class _ToolCard {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  const _ToolCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}
