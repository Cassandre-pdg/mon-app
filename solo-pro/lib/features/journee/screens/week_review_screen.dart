import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class WeekReviewScreen extends StatefulWidget {
  const WeekReviewScreen({super.key});

  @override
  State<WeekReviewScreen> createState() => _WeekReviewScreenState();
}

class _WeekReviewScreenState extends State<WeekReviewScreen> {
  final List<_ReviewQuestion> _questions = [
    _ReviewQuestion(
        emoji: '✅',
        question: 'Qu\'est-ce que j\'ai accompli cette semaine ?',
        hint: 'Mes victoires, petites et grandes...'),
    _ReviewQuestion(
        emoji: '⚡',
        question: 'Qu\'est-ce qui a bien fonctionné ?',
        hint: 'Méthodes, habitudes, outils...'),
    _ReviewQuestion(
        emoji: '🔧',
        question: 'Qu\'est-ce que j\'améliorerais la semaine prochaine ?',
        hint: 'Points à ajuster...'),
    _ReviewQuestion(
        emoji: '🎯',
        question: 'Mes 3 priorités pour la semaine prochaine ?',
        hint: '1.\n2.\n3.'),
  ];

  final List<TextEditingController> _ctrls = [];
  final List<int?> _weekRatings = [null, null, null]; // énergie, productivité, bien-être

  @override
  void initState() {
    super.initState();
    for (var _ in _questions) {
      _ctrls.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Revue de semaine 📅'),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: Text(
              'Enregistrer',
              style: TextStyle(
                color: _canSave ? AppColors.primary : AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Score de la semaine
            const Text('Note ta semaine',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Sur 5 pour chaque dimension',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 14),
            _buildRatingsRow(),
            const SizedBox(height: 28),

            // Questions
            ...List.generate(_questions.length, (i) {
              final q = _questions[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(q.emoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(q.question,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrls[i],
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: q.hint,
                      hintStyle: const TextStyle(
                          color: AppColors.textLight, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.textLight.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.textLight.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _canSave ? _save : null,
                child: const Text('Enregistrer ma revue',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsRow() {
    final labels = ['⚡ Énergie', '🎯 Productivité', '🌿 Bien-être'];
    return Row(
      children: List.generate(3, (dim) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: dim < 2 ? 10 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.textLight.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(labels[dim],
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final val = i + 1;
                    final isSelected = _weekRatings[dim] == val;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _weekRatings[dim] = val),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Icon(
                          isSelected || (_weekRatings[dim] ?? 0) >= val
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 18,
                          color: (_weekRatings[dim] ?? 0) >= val
                              ? AppColors.accentYellow
                              : AppColors.textLight,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  bool get _canSave =>
      _weekRatings.every((r) => r != null) &&
      _ctrls.any((c) => c.text.trim().isNotEmpty);

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Revue de semaine enregistrée !'),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }
}

class _ReviewQuestion {
  final String emoji;
  final String question;
  final String hint;

  const _ReviewQuestion({
    required this.emoji,
    required this.question,
    required this.hint,
  });
}
