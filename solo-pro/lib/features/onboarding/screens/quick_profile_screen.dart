import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';

class QuickProfileScreen extends StatefulWidget {
  const QuickProfileScreen({super.key});

  @override
  State<QuickProfileScreen> createState() => _QuickProfileScreenState();
}

class _QuickProfileScreenState extends State<QuickProfileScreen> {
  final _nameController = TextEditingController();
  String? _selectedMetier;
  String? _selectedObjectif;

  final List<String> _metiers = [
    'Freelance', 'Auto-entrepreneur', 'Consultant', 'Coach',
    'Créateur de contenu', 'Développeur', 'Designer', 'Autre',
  ];

  final List<Map<String, String>> _objectifs = [
    {'emoji': '⚡', 'label': 'Booster ma productivité'},
    {'emoji': '😴', 'label': 'Améliorer mon sommeil'},
    {'emoji': '🧠', 'label': 'Gérer mon énergie'},
    {'emoji': '👥', 'label': 'Trouver une communauté'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text('Profil rapide', style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
              const SizedBox(height: 6),
              const Text('1 minute pour personnaliser ton expérience',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 32),

              // Prénom
              const Text('Ton prénom', style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14,
              )),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ex : Alex',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Métier
              const Text('Ton métier', style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14,
              )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _metiers.map((m) {
                  final selected = _selectedMetier == m;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMetier = m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(m, style: TextStyle(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Objectif
              const Text('Ton objectif principal', style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14,
              )),
              const SizedBox(height: 8),
              ...(_objectifs.map((o) {
                final selected = _selectedObjectif == o['label'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedObjectif = o['label']),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryLight.withValues(alpha: 0.15) : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Text(o['emoji']!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(o['label']!, style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: selected ? AppColors.primary : AppColors.textPrimary,
                        )),
                      ],
                    ),
                  ),
                );
              })),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, AppRoutes.firstCheckin),
                  child: const Text('Continuer'),
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
