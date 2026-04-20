import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Text(
                'SoloPro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Booste ta productivité,\ngère ton énergie.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 2),
              _SocialButton(
                icon: Icons.email_outlined,
                label: 'Continuer avec Email',
                color: AppColors.primary,
                textColor: Colors.white,
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.quickProfile),
              ),
              const SizedBox(height: 12),
              _SocialButton(
                icon: Icons.g_mobiledata,
                label: 'Continuer avec Google',
                color: Colors.white,
                textColor: AppColors.textPrimary,
                border: true,
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.quickProfile),
              ),
              const SizedBox(height: 12),
              _SocialButton(
                icon: Icons.apple,
                label: 'Continuer avec Apple',
                color: Colors.black,
                textColor: Colors.white,
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.quickProfile),
              ),
              const Spacer(),
              const Text(
                'En continuant, tu acceptes nos CGU et politique de confidentialité.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final bool border;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: border ? Border.all(color: AppColors.textLight) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}
