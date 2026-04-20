import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/checkin_models.dart';
import 'solo_bubble.dart';
import 'emoji_scale.dart';
import 'choice_picker.dart';

class CheckinFlow extends StatefulWidget {
  final String title;
  final String emoji;
  final Color accentColor;
  final List<CheckinQuestion> questions;
  final void Function(List<int> answers, double score) onComplete;

  const CheckinFlow({
    super.key,
    required this.title,
    required this.emoji,
    required this.accentColor,
    required this.questions,
    required this.onComplete,
  });

  @override
  State<CheckinFlow> createState() => _CheckinFlowState();
}

class _CheckinFlowState extends State<CheckinFlow>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final List<int?> _answers = [];
  int _currentPage = 0;

  late AnimationController _soloAnim;
  late Animation<double> _soloFade;
  String _soloMessage = '';

  @override
  void initState() {
    super.initState();
    _answers.addAll(List.filled(widget.questions.length, null));
    _soloAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _soloFade = CurvedAnimation(parent: _soloAnim, curve: Curves.easeIn);
    _updateSoloMessage();
    _soloAnim.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _soloAnim.dispose();
    super.dispose();
  }

  void _updateSoloMessage({int? answeredValue}) {
    final q = widget.questions[_currentPage];
    if (answeredValue != null) {
      _soloMessage = q.soloMessage(answeredValue);
    } else {
      // Message d'invite avant réponse
      _soloMessage = _currentPage == 0
          ? 'Salut ! ${widget.title}. Prends un instant pour te connecter à toi-même 🙂'
          : 'Super ! Question ${_currentPage + 1} sur ${widget.questions.length}...';
    }
  }

  void _onAnswer(int value) {
    setState(() {
      _answers[_currentPage] = value;
      _soloMessage = widget.questions[_currentPage].soloMessage(value);
    });
    _soloAnim.reset();
    _soloAnim.forward();
  }

  void _next() {
    if (_answers[_currentPage] == null) return;

    if (_currentPage < widget.questions.length - 1) {
      setState(() {
        _currentPage++;
        _updateSoloMessage();
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _soloAnim.reset();
      _soloAnim.forward();
    } else {
      _finish();
    }
  }

  void _finish() {
    final validAnswers = _answers.whereType<int>().toList();
    final score = computeEnergyScore(validAnswers);
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onComplete(validAnswers, score);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.questions.length,
                itemBuilder: (_, i) => _buildQuestionPage(i),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ─── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close,
                    color: AppColors.textSecondary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.emoji} ${widget.title}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Question ${_currentPage + 1} / ${widget.questions.length}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barre de progression segmentée
          Row(
            children: List.generate(widget.questions.length, (i) {
              final isDone = _answers[i] != null;
              final isCurrent = i == _currentPage;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isDone
                        ? widget.accentColor
                        : isCurrent
                            ? widget.accentColor.withValues(alpha: 0.35)
                            : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Page question ─────────────────────────────────────────────────────────

  Widget _buildQuestionPage(int index) {
    final q = widget.questions[index];
    final isCurrentPage = index == _currentPage;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),

          // Bulle Solo
          FadeTransition(
            opacity: isCurrentPage ? _soloFade : const AlwaysStoppedAnimation(1),
            child: SoloBubble(message: _soloMessage),
          ),

          const SizedBox(height: 32),

          // Question
          Text(
            q.question,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(q.subtitle,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),

          const SizedBox(height: 36),

          // Sélecteur
          if (q.type == QuestionType.emojiScale)
            EmojiScale(
              emojis: q.emojis,
              selected: _answers[index],
              onSelect: (v) {
                if (index == _currentPage) _onAnswer(v);
              },
            )
          else
            ChoicePicker(
              emojis: q.emojis,
              labels: q.choiceLabels!,
              selected: _answers[index],
              onSelect: (v) {
                if (index == _currentPage) _onAnswer(v);
              },
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final canAdvance = _answers[_currentPage] != null;
    final isLast = _currentPage == widget.questions.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: canAdvance ? _next : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canAdvance ? widget.accentColor : AppColors.surfaceVariant,
            foregroundColor: canAdvance ? Colors.white : AppColors.textLight,
            elevation: canAdvance ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            isLast ? 'Voir mon score 🎯' : 'Question suivante →',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
