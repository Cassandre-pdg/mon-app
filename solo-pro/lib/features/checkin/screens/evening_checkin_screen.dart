import 'package:flutter/material.dart';
import '../models/checkin_models.dart';
import '../widgets/checkin_flow.dart';
import 'checkin_result_screen.dart';

class EveningCheckinScreen extends StatelessWidget {
  const EveningCheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CheckinFlow(
      title: 'Check-in du soir',
      emoji: '🌙',
      accentColor: const Color(0xFF3D35CC),
      questions: eveningQuestions,
      onComplete: (answers, score) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CheckinResultScreen(
              score: score,
              isMorning: false,
              answers: answers,
            ),
          ),
        );
      },
    );
  }
}
