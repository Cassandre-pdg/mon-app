import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/checkin_models.dart';
import '../widgets/checkin_flow.dart';
import 'checkin_result_screen.dart';

class MorningCheckinScreen extends StatelessWidget {
  const MorningCheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CheckinFlow(
      title: 'Check-in du matin',
      emoji: '☀️',
      accentColor: AppColors.primary,
      questions: morningQuestions,
      onComplete: (answers, score) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CheckinResultScreen(
              score: score,
              isMorning: true,
              answers: answers,
            ),
          ),
        );
      },
    );
  }
}
