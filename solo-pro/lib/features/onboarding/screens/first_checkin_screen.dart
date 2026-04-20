import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';

class FirstCheckinScreen extends StatefulWidget {
  const FirstCheckinScreen({super.key});

  @override
  State<FirstCheckinScreen> createState() => _FirstCheckinScreenState();
}

class _FirstCheckinScreenState extends State<FirstCheckinScreen> {
  int _step = 0;
  int? _energyLevel;
  int? _moodLevel;
  int? _sleepQuality;

  final List<Map<String, dynamic>> _steps = [
    {
      'question': 'Comment tu te sens en ce moment ?',
      'subtitle': 'Évalue ton énergie de 1 à 5',
      'emojis': ['😴', '😔', '😐', '😊', '🚀'],
    },
    {
      'question': 'Comment était ton humeur ce matin ?',
      'subtitle': 'Sois honnête, c\'est juste pour toi',
      'emojis': ['😤', '😟', '😐', '🙂', '😁'],
    },
    {
      'question': 'Comment as-tu dormi cette nuit ?',
      'subtitle': 'Qualité de ton sommeil',
      'emojis': ['💀', '😩', '😐', '😌', '🌟'],
    },
  ];

  void _selectAnswer(int val) {
    setState(() {
      if (_step == 0) _energyLevel = val;
      if (_step == 1) _moodLevel = val;
      if (_step == 2) _sleepQuality = val;
    });
  }

  int? get _currentAnswer {
    if (_step == 0) return _energyLevel;
    if (_step == 1) return _moodLevel;
    return _sleepQuality;
  }

  @override
  Widget build(BuildContext context) {
    final s = _steps[_step];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Solo le personnage
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Text('🤖',
                          style: TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Salut ! Je suis Solo 👋\nRéponds à 3 questions rapides pour commencer.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Indicateur d'étape
              Row(
                children: List.generate(3, (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _step ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 8),
              Text('Question ${_step + 1} / 3',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),

              const SizedBox(height: 32),

              Text(s['question'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 8),
              Text(s['subtitle'] as String,
                  style: const TextStyle(color: AppColors.textSecondary)),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final val = i + 1;
                  final selected = _currentAnswer == val;
                  return GestureDetector(
                    onTap: () => _selectAnswer(val),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: selected ? 64 : 54,
                      height: selected ? 64 : 54,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: selected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text((s['emojis'] as List<String>)[i],
                              style: TextStyle(fontSize: selected ? 28 : 24)),
                          Text('$val', style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textLight,
                          )),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentAnswer == null
                      ? null
                      : () {
                          if (_step < 2) {
                            setState(() => _step++);
                          } else {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.home);
                          }
                        },
                  child: Text(_step < 2 ? 'Question suivante' : 'Voir mon tableau de bord'),
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
