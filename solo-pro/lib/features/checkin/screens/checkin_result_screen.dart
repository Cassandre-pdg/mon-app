import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CheckinResultScreen extends StatefulWidget {
  final double score;
  final bool isMorning;
  final List<int> answers;

  const CheckinResultScreen({
    super.key,
    required this.score,
    required this.isMorning,
    required this.answers,
  });

  @override
  State<CheckinResultScreen> createState() => _CheckinResultScreenState();
}

class _CheckinResultScreenState extends State<CheckinResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scoreFill;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _scoreFill = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _scoreLabel {
    if (widget.score >= 8) return 'Excellent !';
    if (widget.score >= 6) return 'Bien !';
    if (widget.score >= 4) return 'Correct';
    return 'À surveiller';
  }

  Color get _scoreColor {
    if (widget.score >= 7) return AppColors.accentGreen;
    if (widget.score >= 4) return AppColors.accentYellow;
    return AppColors.accent;
  }

  String get _soloResultMessage {
    if (widget.isMorning) {
      if (widget.score >= 8) return 'Quelle pêche ce matin ! C\'est une journée pour viser haut 🚀';
      if (widget.score >= 6) return 'Belle énergie ! Tu as tout ce qu\'il faut pour une bonne journée 😊';
      if (widget.score >= 4) return 'Ça ira. Commence par une petite tâche pour prendre de l\'élan 💪';
      return 'Journée difficile en vue. Sois indulgent(e) avec toi-même aujourd\'hui 💙';
    } else {
      if (widget.score >= 8) return 'Quelle belle journée ! Capitalise sur cette énergie demain 🌟';
      if (widget.score >= 6) return 'Bonne journée dans l\'ensemble. Tu avances dans la bonne direction 👍';
      if (widget.score >= 4) return 'Journée mitigée. Repose-toi bien ce soir pour demain 🌙';
      return 'Journée dure. Prends soin de toi ce soir, tu mérites du repos 💙';
    }
  }

  String get _tipMessage {
    if (widget.isMorning) {
      if (widget.score >= 7) return 'Lance-toi sur ta tâche la plus difficile maintenant pendant que tu es au max.';
      if (widget.score >= 4) return 'Commence par une tâche facile pour te mettre en route, puis monte en puissance.';
      return 'Si possible, élimine les distractions et garde ton énergie pour l\'essentiel.';
    } else {
      if (widget.score >= 7) return 'Note 3 victoires de la journée avant de dormir. Ça renforce la confiance.';
      if (widget.score >= 4) return 'Prépare tes 3 priorités de demain maintenant pendant que c\'est frais.';
      return 'Déconnecte les écrans 30 min avant de dormir pour récupérer au max.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context)
                      ..pop()
                      ..pop(),
                    child: const Icon(Icons.close,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isMorning
                        ? '☀️ Check-in du matin'
                        : '🌙 Check-in du soir',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),

              const Spacer(),

              // Score animé
              AnimatedBuilder(
                animation: _scoreFill,
                builder: (_, __) {
                  final displayed =
                      (widget.score * _scoreFill.value);
                  return Column(
                    children: [
                      // Cercle score
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: CircularProgressIndicator(
                                value: displayed / 10,
                                strokeWidth: 12,
                                backgroundColor:
                                    _scoreColor.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _scoreColor),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  displayed.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: _scoreColor,
                                    height: 1,
                                  ),
                                ),
                                const Text('/10',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _scoreLabel,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _scoreColor,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Message Solo
              FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    // Bulle Solo
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                                child: Text('🤖',
                                    style: TextStyle(fontSize: 20))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _soloResultMessage,
                              style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Conseil du jour
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _scoreColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _scoreColor.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _tipMessage,
                              style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bouton retour
              FadeTransition(
                opacity: _fadeIn,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                      ..pop()
                      ..pop(),
                    child: const Text(
                      'Retour au tableau de bord',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
